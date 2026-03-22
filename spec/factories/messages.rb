FactoryBot.define do
  factory :message do
    association :conversation
    association :sender, factory: [:tenant_user, :approved]
    body { Faker::Lorem.sentence }
  end
end
