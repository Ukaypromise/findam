module Types
  class Objects::PlatformStatsType < Types::BaseObject
    field :total_users, Integer, null: false
    field :total_landlords, Integer, null: false
    field :total_tenants, Integer, null: false
    field :total_listings, Integer, null: false
    field :active_listings, Integer, null: false
    field :total_commission_paid, Float, null: false
    field :monthly_revenue, Float, null: false
  end
end
