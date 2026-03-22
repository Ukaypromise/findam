module Types
  class Objects::LandlordProfileType < Types::BaseObject
    field :id, ID, null: false
    field :type, String, null: false
    field :user_id, Integer, null: false
    field :full_name, String, null: true
    field :location, String, null: true
    field :short_bio, String, null: true
    field :phone_number, String, null: true
    field :is_nin_verified, Boolean, null: false
    field :is_certified, Boolean, null: false
    field :is_top_landlord, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def is_nin_verified
      object.nin_verified
    end

    def is_certified
      object.certified
    end

    def is_top_landlord
      object.top_landlord
    end
  end
end
