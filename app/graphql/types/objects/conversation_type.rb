module Types
  class Objects::ConversationType < Types::BaseObject
    field :id, ID, null: false
    field :tenant_id, Integer, null: false
    field :landlord_id, Integer, null: false
    field :listing_id, Integer, null: false
    field :last_message_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :tenant, Types::Objects::TenantType, null: false
    field :landlord, Types::Objects::LandlordType, null: false
    field :listing, Types::Objects::ListingType, null: false
    field :messages, [Types::Objects::MessageType], null: false

    def messages
      object.messages.ordered
    end
  end
end
