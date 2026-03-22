# frozen_string_literal: true

module Types
  class SubscriptionType < Types::BaseObject
    field :test_event, String, null: false do
      argument :message, String, required: false
    end

    def test_event(message: "Hello from subscription!")
      message
    end
  end
end
