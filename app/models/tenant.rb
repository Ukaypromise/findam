class Tenant < User
  has_one :tenant_profile, class_name: "TenantProfile", foreign_key: "user_id", dependent: :destroy
  has_many :inspection_bookings, foreign_key: :tenant_id, dependent: :destroy
end
