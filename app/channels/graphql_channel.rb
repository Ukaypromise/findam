# frozen_string_literal: true

class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    @subscription_ids = []
  end

  def execute(data)
    result = FindamSchema.execute(
      query: data["query"],
      context: { channel: self },
      variables: ensure_hash(data["variables"]),
      operation_name: data["operationName"]
    )

    transmit(
      result: result.to_h,
      more: result.subscription?
    )

    sid = result.context[:subscription_id]
    @subscription_ids << sid if sid
  end

  def unsubscribed
    @subscription_ids.each do |sid|
      FindamSchema.subscriptions.delete_subscription(sid)
    end
  end

  private

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      ambiguous_param.present? ? JSON.parse(ambiguous_param) : {}
    when Hash, NilClass
      ambiguous_param || {}
    else
      {}
    end
  end
end
