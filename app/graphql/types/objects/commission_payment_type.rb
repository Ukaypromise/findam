module Types
  class Objects::CommissionPaymentType < Types::BaseObject
    field :id, ID, null: false
    field :listing_id, Integer, null: false
    field :tenant_id, Integer, null: false
    field :landlord_id, Integer, null: false
    field :amount, Float, null: true
    field :tenant_percentage, Float, null: true
    field :landlord_percentage, Float, null: true
    field :status, String, null: false
    field :paystack_reference, String, null: true
    field :paid_at, GraphQL::Types::ISO8601DateTime, null: true
    field :payment_url, String, null: true
    field :landlord_confirmed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :tenant_confirmed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :listing, Types::Objects::ListingType, null: false
    field :tenant, Types::Objects::TenantType, null: false
    field :landlord, Types::Objects::LandlordType, null: false
  end
end
