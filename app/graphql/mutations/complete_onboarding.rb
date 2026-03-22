# frozen_string_literal: true

module Mutations
  class CompleteOnboarding < Mutations::BaseMutation
    description "Complete the user's onboarding and submit for review"

    field :landlord, Types::Objects::LandlordType, null: true
    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      ActiveRecord::Base.transaction do
        current_user.update!(
          onboarding_completed: true,
          onboarding_completed_at: Time.current
        )

        unless current_user.submit_for_review
          raise GraphQL::ExecutionError, "Cannot submit for review from current status: #{current_user.approval_status}"
        end
      end

      {
        landlord: current_user.reload,
        success: true,
        errors: []
      }
    rescue ActiveRecord::RecordInvalid => e
      { landlord: nil, success: false, errors: e.record.errors.full_messages }
    end
  end
end
