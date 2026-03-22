class Listing < ApplicationRecord
  belongs_to :landlord, class_name: "User", foreign_key: :landlord_id

  has_many :conversations, dependent: :destroy
  has_many :inspection_slots, dependent: :destroy
  has_many :inspection_bookings, dependent: :destroy
  has_many :commission_payments, dependent: :destroy
  has_many :flagged_listings, dependent: :destroy

  has_many_attached :photos
  has_one_attached :document

  enum :property_type, {
    flat: "flat",
    duplex: "duplex",
    bungalow: "bungalow",
    self_contain: "self_contain",
    room_and_parlour: "room_and_parlour"
  }, prefix: true

  state_machine :status, initial: :draft do
    state :draft
    state :published
    state :rented
    state :removed

    event :publish do
      transition :draft => :published
    end

    event :rent do
      transition :published => :rented
    end

    event :remove do
      transition [:draft, :published, :rented] => :removed
    end

    event :republish do
      transition [:rented, :removed] => :published
    end
  end

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :address, presence: true
  validates :city, presence: true
  validates :property_type, presence: true
  validate :landlord_must_be_approved, on: :create

  scope :available, -> { where(is_available: true) }
  scope :published, -> { with_status(:published) }
  scope :not_removed, -> { without_status(:removed) }
  scope :by_city, ->(city) { where("LOWER(city) = ?", city.downcase) if city.present? }
  scope :by_price_range, ->(min, max) {
    scope = all
    scope = scope.where("price >= ?", min) if min.present?
    scope = scope.where("price <= ?", max) if max.present?
    scope
  }
  scope :by_property_type, ->(type) { where(property_type: type) if type.present? }

  private

  def landlord_must_be_approved
    if landlord && landlord.approval_status != "approved"
      errors.add(:landlord, "must have approved status to create listings")
    end
  end
end
