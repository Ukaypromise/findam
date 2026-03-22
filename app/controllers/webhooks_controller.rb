class WebhooksController < ApplicationController
  skip_forgery_protection only: :paystack

  def paystack
    payload = request.body.read
    signature = request.headers["X-Paystack-Signature"]

    unless PaymentService.verify_webhook_signature(payload, signature)
      head :unauthorized
      return
    end

    event = JSON.parse(payload)
    reference = event.dig("data", "reference")

    commission_payment = CommissionPayment.find_by(paystack_reference: reference)

    unless commission_payment
      head :not_found
      return
    end

    case event["event"]
    when "charge.success"
      commission_payment.mark_paid
    when "charge.failed"
      commission_payment.mark_failed
    end

    head :ok
  rescue JSON::ParserError
    head :bad_request
  end
end
