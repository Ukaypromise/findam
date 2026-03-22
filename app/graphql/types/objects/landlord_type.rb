module Types
  class Objects::LandlordType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :type, String, null: false
    field :uid, String, null: false
    field :provider, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
