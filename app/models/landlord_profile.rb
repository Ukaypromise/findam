class LandlordProfile < Profile
  belongs_to :landlord, class_name: "User", foreign_key: "user_id"

  has_one_attached :profile_picture

end
