module Types
  class Objects::InspectionBookingType < Types::BaseObject
    field :id, ID, null: false
    field :tenant_id, Integer, null: false
    field :landlord_id, Integer, null: false
    field :listing_id, Integer, null: false
    field :inspection_slot_id, Integer, null: false
    field :status, String, null: false
    field :cancelled_by, String, null: true
    field :cancellation_reason, String, null: true
    field :confirmed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :tenant, Types::Objects::TenantType, null: false
    field :landlord, Types::Objects::LandlordType, null: false
    field :listing, Types::Objects::ListingType, null: false
    field :inspection_slot, Types::Objects::InspectionSlotType, null: false
  end
end
