FactoryBot.define do
  factory :listing do
    association :landlord, factory: [:landlord, :approved]
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    price { Faker::Number.decimal(l_digits: 6, r_digits: 2) }
    address { Faker::Address.street_address }
    city { "Lagos" }
    property_type { "flat" }
    bedrooms { 2 }
    bathrooms { 1 }
    is_available { true }
    status { "published" }

    trait :draft do
      status { "draft" }
    end

    trait :removed do
      status { "removed" }
    end
  end
end
