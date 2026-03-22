module Mutations
  class ToggleListingAvailability < BaseMutation
    description "Toggle listing availability (owner only)"

    argument :id, ID, required: true

    field :listing, Types::Objects::ListingType, null: true
    field :errors, [ String ], null: false

    def resolve(id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      listing = Listing.find(id)
      raise GraphQL::ExecutionError, "Not authorized" unless listing.landlord_id == current_user.id

      listing.update!(is_available: !listing.is_available)

      { listing: listing, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { listing: nil, errors: e.record.errors.full_messages }
    end
  end
end
