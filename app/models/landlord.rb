class Landlord < User
  has_one :landlord_profile, class_name: "Landlord_Profile", foreign_key: "user_id", dependent: :destroy
end
