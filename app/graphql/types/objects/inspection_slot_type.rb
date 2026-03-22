module Types
  class Objects::InspectionSlotType < Types::BaseObject
    field :id, ID, null: false
    field :landlord_id, Integer, null: false
    field :listing_id, Integer, null: false
    field :starts_at, GraphQL::Types::ISO8601DateTime, null: false
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: false
    field :is_booked, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :listing, Types::Objects::ListingType, null: false
  end
end
