module Mutations
  class MarkMessagesRead < BaseMutation
    description "Mark all messages in a conversation as read"

    argument :conversation_id, ID, required: true

    field :conversation, Types::Objects::ConversationType, null: true
    field :errors, [ String ], null: false

    def resolve(conversation_id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      conversation = Conversation.find(conversation_id)

      unless conversation.tenant_id == current_user.id || conversation.landlord_id == current_user.id
        raise GraphQL::ExecutionError, "Not authorized"
      end

      conversation.messages
        .where.not(sender_id: current_user.id)
        .where(read_at: nil)
        .update_all(read_at: Time.current)

      { conversation: conversation, errors: [] }
    end
  end
end
