module Types
  class Objects::TenantProfileType < Types::BaseObject
    field :id, ID, null: false
    field :type, String, null: false
    field :user_id, Integer, null: false
    field :full_name, String
    field :location, String
    field :short_bio, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
