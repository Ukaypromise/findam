module Types
  class Objects::FlaggedListingType < Types::BaseObject
    field :id, ID, null: false
    field :listing_id, Integer, null: false
    field :reporter_id, Integer, null: false
    field :reason, String, null: false
    field :resolved, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :listing, Types::Objects::ListingType, null: false
    field :reporter, Types::Objects::UserType, null: false
  end
end
