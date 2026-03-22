# frozen_string_literal: true

module Types
  class SubscriptionType < Types::BaseObject
    field :message_received, Types::Objects::MessageType, null: false do
      argument :conversation_id, ID, required: true
    end

    def message_received(conversation_id:)
      object
    end

    field :inspection_status_changed, Types::Objects::InspectionBookingType, null: false do
      argument :booking_id, ID, required: true
    end

    def inspection_status_changed(booking_id:)
      object
    end
  end
end
