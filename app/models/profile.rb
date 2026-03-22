class Profile < ApplicationRecord
  TYPES = %w[LandlordProfile TenantProfile].freeze


  belongs_to :user

  validates :type, presence: true, inclusion: { in: TYPES }
  validates :full_name, presence: true, on: :update
end
