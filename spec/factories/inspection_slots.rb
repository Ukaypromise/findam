FactoryBot.define do
  factory :inspection_slot do
    association :landlord, factory: [ :landlord, :approved ]
    association :listing
    starts_at { 1.day.from_now }
    ends_at { 1.day.from_now + 2.hours }
    is_booked { false }
  end
end
