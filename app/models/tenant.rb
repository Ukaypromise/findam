class Tenant < User
  has_one :tenant_profile, class_name: "Tenant_Profile", foreign_key: "user_id", dependent: :destroy
end
