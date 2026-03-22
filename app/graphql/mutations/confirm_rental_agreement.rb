module Mutations
  class ConfirmRentalAgreement < BaseMutation
    description "Confirm rental agreement (both parties must call)"

    argument :listing_id, ID, required: true

    field :commission_payment, Types::Objects::CommissionPaymentType, null: true
    field :payment_url, String, null: true
    field :errors, [String], null: false

    def resolve(listing_id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      listing = Listing.find(listing_id)

      commission_payment = CommissionPayment.find_by(listing_id: listing.id) ||
        CommissionPayment.new(
          listing: listing,
          landlord_id: listing.landlord_id,
          amount: listing.price * 0.04,
          tenant_percentage: 2.5,
          landlord_percentage: 1.5,
          status: "pending"
        )

      ActiveRecord::Base.transaction do
        if current_user.landlord? && listing.landlord_id == current_user.id
          commission_payment.landlord_confirmed_at = Time.current
          commission_payment.tenant_id ||= listing.conversations.first&.tenant_id
        elsif current_user.tenant?
          commission_payment.tenant_id = current_user.id
          commission_payment.tenant_confirmed_at = Time.current
        else
          raise GraphQL::ExecutionError, "Not authorized"
        end

        commission_payment.save!

        if commission_payment.both_parties_confirmed?
          service = PaymentService.new(commission_payment)
          result = service.create_payment_link
          return { commission_payment: commission_payment.reload, payment_url: result[:payment_url], errors: [] }
        end
      end

      { commission_payment: commission_payment, payment_url: nil, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { commission_payment: nil, payment_url: nil, errors: e.record.errors.full_messages }
    end
  end
end
