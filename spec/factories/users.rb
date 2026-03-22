FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    provider { "email" }
    uid { email }
    confirmed_at { Time.current }

    factory :landlord, class: "Landlord" do
      type { "Landlord" }

      trait :approved do
        approval_status { "approved" }
        approved_at { Time.current }
        onboarding_completed { true }
        onboarding_completed_at { Time.current }
      end

      trait :submitted do
        approval_status { "submitted" }
        onboarding_completed { true }
        onboarding_completed_at { Time.current }
      end
    end

    factory :tenant_user, class: "Tenant" do
      type { "Tenant" }

      trait :approved do
        approval_status { "approved" }
        approved_at { Time.current }
        onboarding_completed { true }
        onboarding_completed_at { Time.current }
      end
    end

    factory :admin_user, class: "Admin" do
      type { "Admin" }
      approval_status { "approved" }
    end
  end
end
