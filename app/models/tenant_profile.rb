class TenantProfile < Profile
  belongs_to :tenant, class_name: "User", foreign_key: "user_id"

  has_one_attached :profile_picture
end
