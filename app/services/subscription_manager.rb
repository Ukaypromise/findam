# frozen_string_literal: true

class SubscriptionManager
  def self.trigger_test_event(message = "Test event triggered!")
    FindamSchema.subscriptions.trigger(
      :test_event,
      {},
      message
    )
  end
end
