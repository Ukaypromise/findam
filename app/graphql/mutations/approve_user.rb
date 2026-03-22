module Mutations
  class ApproveUser < BaseMutation
    description "Approve a user (admin only)"

    argument :user_id, ID, required: true

    field :user, Types::Objects::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(user_id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user&.admin?

      user = User.find(user_id)
      user.approve!

      UserApprovalMailer.approval_email(user).deliver_later

      { user: user, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { user: nil, errors: e.record.errors.full_messages }
    end
  end
end
