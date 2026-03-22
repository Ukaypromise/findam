class CommissionPayment < ApplicationRecord
  belongs_to :listing
  belongs_to :tenant, class_name: "User", foreign_key: :tenant_id, optional: true
  belongs_to :landlord, class_name: "User", foreign_key: :landlord_id

  state_machine :status, initial: :pending do
    state :pending
    state :paid
    state :failed
    state :refunded

    event :mark_paid do
      transition pending: :paid
    end

    event :mark_failed do
      transition pending: :failed
    end

    event :refund do
      transition paid: :refunded
    end

    after_transition any => :paid do |payment|
      payment.update_columns(paid_at: Time.current)
    end
  end

  scope :for_listing, ->(listing_id) { where(listing_id: listing_id) }

  def both_parties_confirmed?
    landlord_confirmed_at.present? && tenant_confirmed_at.present?
  end
end
