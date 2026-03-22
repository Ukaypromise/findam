class PaymentService
  PAYSTACK_BASE_URL = "https://api.paystack.co".freeze

  def initialize(commission_payment)
    @commission_payment = commission_payment
  end

  def create_payment_link
    # TODO: Make actual HTTP call to Paystack API
    # POST https://api.paystack.co/transaction/initialize
    # Headers: Authorization: Bearer SECRET_KEY
    # Body: { email: tenant_email, amount: amount_in_kobo, reference: reference, callback_url: ... }
    #
    # response = HTTParty.post(
    #   "#{PAYSTACK_BASE_URL}/transaction/initialize",
    #   headers: {
    #     "Authorization" => "Bearer #{ENV['PAYSTACK_SECRET_KEY']}",
    #     "Content-Type" => "application/json"
    #   },
    #   body: {
    #     email: @commission_payment.tenant.email,
    #     amount: (@commission_payment.amount * 100).to_i,
    #     reference: reference,
    #     callback_url: ENV['PAYSTACK_CALLBACK_URL']
    #   }.to_json
    # )

    reference = generate_reference
    payment_url = "https://checkout.paystack.com/#{reference}"

    @commission_payment.update!(
      paystack_reference: reference,
      payment_url: payment_url
    )

    { payment_url: payment_url, reference: reference }
  end

  def verify_payment(reference)
    # TODO: Make actual HTTP call to Paystack API
    # GET https://api.paystack.co/transaction/verify/:reference
    # Headers: Authorization: Bearer SECRET_KEY
    #
    # response = HTTParty.get(
    #   "#{PAYSTACK_BASE_URL}/transaction/verify/#{reference}",
    #   headers: {
    #     "Authorization" => "Bearer #{ENV['PAYSTACK_SECRET_KEY']}"
    #   }
    # )
    # return response.parsed_response

    { status: "success", data: { status: "success", reference: reference } }
  end

  def self.verify_webhook_signature(payload, signature)
    # TODO: Implement actual HMAC verification
    # expected = OpenSSL::HMAC.hexdigest("SHA512", ENV['PAYSTACK_SECRET_KEY'], payload)
    # ActiveSupport::SecurityUtils.secure_compare(expected, signature)
    signature.present?
  end

  private

  def generate_reference
    "FINDAM-#{SecureRandom.hex(10)}"
  end
end
