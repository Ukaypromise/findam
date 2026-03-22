module Mutations
  class CreateInspectionSlot < BaseMutation
    description "Create an inspection time slot (landlord only)"

    argument :listing_id, ID, required: true
    argument :starts_at, GraphQL::Types::ISO8601DateTime, required: true
    argument :ends_at, GraphQL::Types::ISO8601DateTime, required: true

    field :inspection_slot, Types::Objects::InspectionSlotType, null: true
    field :errors, [String], null: false

    def resolve(listing_id:, starts_at:, ends_at:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user
      raise GraphQL::ExecutionError, "Only landlords can create inspection slots" unless current_user.landlord?

      listing = Listing.find(listing_id)
      raise GraphQL::ExecutionError, "Not authorized" unless listing.landlord_id == current_user.id

      slot = InspectionSlot.create!(
        landlord: current_user,
        listing: listing,
        starts_at: starts_at,
        ends_at: ends_at
      )

      { inspection_slot: slot, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { inspection_slot: nil, errors: e.record.errors.full_messages }
    end
  end
end
