# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :user_registration, mutation: Mutations::UserRegistration, authenticate: false
    field :complete_student_onboarding, mutation: Mutations::CompleteStudentOnboarding
  end
end
