FactoryBot.define do
  factory :commission_payment do
    association :listing
    association :tenant, factory: [:tenant_user, :approved]
    association :landlord, factory: [:landlord, :approved]
    amount { 50000.00 }
    tenant_percentage { 2.5 }
    landlord_percentage { 1.5 }
    status { "pending" }
  end
end
