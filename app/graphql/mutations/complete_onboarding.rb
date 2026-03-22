# frozen_string_literal: true

module Mutations
  class CompleteOnboarding < Mutations::BaseMutation
    description "Complete the landlord's onboarding"

    field :landlord, Types::Objects::LandlordType, null: true
    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve
      current_user.update(
        onboarding_completed: true,
        onboarding_completed_at: Time.current,
        approval_status: "submitted"
      )

      raise GraphQL::ExecutionError.new "Error submitting onboarding", extensions: current_user.errors.to_hash unless current_user.save

      {
        iec_user: current_user.reload,
        success: true,
        errors: []
      }
    end
  end
end
