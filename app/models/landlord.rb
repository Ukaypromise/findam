class Landlord < User
  has_one :landlord_profile, class_name: "LandlordProfile", foreign_key: "user_id", dependent: :destroy
  has_many :listings, foreign_key: :landlord_id, dependent: :destroy
  has_many :inspection_slots, foreign_key: :landlord_id, dependent: :destroy
end
