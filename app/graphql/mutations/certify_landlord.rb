module Mutations
  class CertifyLandlord < BaseMutation
    description "Certify a landlord (admin only)"

    argument :landlord_id, ID, required: true

    field :landlord_profile, Types::Objects::LandlordProfileType, null: true
    field :errors, [String], null: false

    def resolve(landlord_id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user&.admin?

      landlord = User.find(landlord_id)
      raise GraphQL::ExecutionError, "User is not a landlord" unless landlord.landlord?

      profile = landlord.profile
      profile.update!(
        certified: true,
        certified_at: Time.current
      )

      { landlord_profile: profile, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { landlord_profile: nil, errors: e.record.errors.full_messages }
    end
  end
end
