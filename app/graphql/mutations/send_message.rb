module Mutations
  class SendMessage < BaseMutation
    description "Send a message to another user about a listing"

    argument :recipient_id, ID, required: true
    argument :listing_id, ID, required: true
    argument :body, String, required: true

    field :message, Types::Objects::MessageType, null: true
    field :errors, [ String ], null: false

    def resolve(recipient_id:, listing_id:, body:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      recipient = User.find(recipient_id)
      listing = Listing.find(listing_id)

      tenant_id, landlord_id = if current_user.tenant?
        [ current_user.id, recipient.id ]
      else
        [ recipient.id, current_user.id ]
      end

      message = nil

      ActiveRecord::Base.transaction do
        conversation = Conversation.find_or_create_by!(
          tenant_id: tenant_id,
          landlord_id: landlord_id,
          listing_id: listing.id
        )

        message = conversation.messages.create!(
          sender: current_user,
          body: body
        )
      end

      FindamSchema.subscriptions.trigger(
        :message_received,
        { conversation_id: message.conversation_id },
        message
      )

      { message: message, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { message: nil, errors: e.record.errors.full_messages }
    end
  end
end
