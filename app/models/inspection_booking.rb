class InspectionBooking < ApplicationRecord
  belongs_to :tenant, class_name: "User", foreign_key: :tenant_id
  belongs_to :landlord, class_name: "User", foreign_key: :landlord_id
  belongs_to :listing
  belongs_to :inspection_slot

  state_machine :status, initial: :pending do
    state :pending
    state :confirmed
    state :cancelled
    state :completed

    event :confirm do
      transition :pending => :confirmed
    end

    event :cancel do
      transition [:pending, :confirmed] => :cancelled
    end

    event :complete do
      transition :confirmed => :completed
    end

    after_transition any => :confirmed do |booking|
      booking.update_columns(confirmed_at: Time.current)
    end

    after_transition any => :cancelled do |booking|
      booking.inspection_slot.update!(is_booked: false)
    end
  end

  scope :active, -> { without_status(:cancelled) }
end
