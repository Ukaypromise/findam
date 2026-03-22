FactoryBot.define do
  factory :inspection_booking do
    association :tenant, factory: [ :tenant_user, :approved ]
    association :landlord, factory: [ :landlord, :approved ]
    association :listing
    association :inspection_slot
    status { "pending" }
  end
end
