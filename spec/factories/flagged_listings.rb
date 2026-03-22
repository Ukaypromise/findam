FactoryBot.define do
  factory :flagged_listing do
    association :listing
    association :reporter, factory: [:tenant_user, :approved]
    reason { "Suspicious listing" }
    resolved { false }
  end
end
