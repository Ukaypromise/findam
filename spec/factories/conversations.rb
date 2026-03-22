FactoryBot.define do
  factory :conversation do
    association :tenant, factory: [:tenant_user, :approved]
    association :landlord, factory: [:landlord, :approved]
    association :listing
    last_message_at { Time.current }
  end
end
