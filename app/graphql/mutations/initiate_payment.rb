module Mutations
  class InitiatePayment < BaseMutation
    description "Initiate a commission payment (tenant only)"

    argument :listing_id, ID, required: true

    field :commission_payment, Types::Objects::CommissionPaymentType, null: true
    field :payment_url, String, null: true
    field :errors, [ String ], null: false

    def resolve(listing_id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user
      raise GraphQL::ExecutionError, "Only tenants can initiate payments" unless current_user.tenant?

      listing = Listing.find(listing_id)

      commission_payment = CommissionPayment.create!(
        listing: listing,
        tenant: current_user,
        landlord_id: listing.landlord_id,
        amount: listing.price * 0.04,
        tenant_percentage: 2.5,
        landlord_percentage: 1.5,
        status: "pending"
      )

      service = PaymentService.new(commission_payment)
      result = service.create_payment_link

      { commission_payment: commission_payment.reload, payment_url: result[:payment_url], errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { commission_payment: nil, payment_url: nil, errors: e.record.errors.full_messages }
    end
  end
end
