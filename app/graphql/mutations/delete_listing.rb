module Mutations
  class DeleteListing < BaseMutation
    description "Soft delete a listing by setting status to removed (owner only)"

    argument :id, ID, required: true

    field :listing, Types::Objects::ListingType, null: true
    field :errors, [ String ], null: false

    def resolve(id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      listing = Listing.find(id)
      raise GraphQL::ExecutionError, "Not authorized" unless listing.landlord_id == current_user.id

      unless listing.remove
        raise GraphQL::ExecutionError, "Cannot remove listing from current status: #{listing.status}"
      end

      { listing: listing, errors: [] }
    end
  end
end
