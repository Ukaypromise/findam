class InspectionSlot < ApplicationRecord
  belongs_to :landlord, class_name: "User", foreign_key: :landlord_id
  belongs_to :listing

  has_many :inspection_bookings, dependent: :destroy

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_at_after_starts_at

  scope :available, -> { where(is_booked: false).where("starts_at > ?", Time.current) }
  scope :for_listing, ->(listing_id) { where(listing_id: listing_id) }

  private

  def ends_at_after_starts_at
    return unless starts_at && ends_at

    if ends_at <= starts_at
      errors.add(:ends_at, "must be after starts_at")
    end
  end
end
