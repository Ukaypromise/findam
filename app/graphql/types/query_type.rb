# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :current_user, Types::Objects::UserType, null: true

    def current_user
      context[:current_resource]
    end

    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Listings
    field :listings, [ Types::Objects::ListingType ], null: false do
      argument :city, String, required: false
      argument :price_min, Float, required: false
      argument :price_max, Float, required: false
      argument :property_type, String, required: false
      argument :page, Integer, required: false
      argument :per_page, Integer, required: false
    end

    def listings(city: nil, price_min: nil, price_max: nil, property_type: nil, page: 1, per_page: 20)
      scope = Listing.available.published
      scope = scope.by_city(city) if city.present?
      scope = scope.by_price_range(price_min, price_max)
      scope = scope.by_property_type(property_type) if property_type.present?
      scope.order(created_at: :desc).page(page).per(per_page)
    end

    field :listing, Types::Objects::ListingType, null: true do
      argument :id, ID, required: true
    end

    def listing(id:)
      Listing.find(id)
    end

    # Conversations
    field :conversations, [ Types::Objects::ConversationType ], null: false

    def conversations
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      Conversation.for_user(current_user).ordered
    end

    field :messages, [ Types::Objects::MessageType ], null: false do
      argument :conversation_id, ID, required: true
      argument :page, Integer, required: false
    end

    def messages(conversation_id:, page: 1)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      conversation = Conversation.find(conversation_id)

      unless conversation.tenant_id == current_user.id || conversation.landlord_id == current_user.id
        raise GraphQL::ExecutionError, "Not authorized"
      end

      # Mark messages as read
      conversation.messages
        .where.not(sender_id: current_user.id)
        .where(read_at: nil)
        .update_all(read_at: Time.current)

      conversation.messages.ordered.page(page).per(50)
    end

    # Inspections
    field :available_slots, [ Types::Objects::InspectionSlotType ], null: false do
      argument :listing_id, ID, required: true
    end

    def available_slots(listing_id:)
      InspectionSlot.available.for_listing(listing_id).order(starts_at: :asc)
    end

    # Admin queries
    field :pending_approvals, [ Types::Objects::UserType ], null: false

    def pending_approvals
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user&.admin?

      User.where(approval_status: [ "pending", "submitted" ]).order(created_at: :asc)
    end

    field :platform_stats, Types::Objects::PlatformStatsType, null: false

    def platform_stats
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user&.admin?

      {
        total_users: User.count,
        total_landlords: Landlord.count,
        total_tenants: Tenant.count,
        total_listings: Listing.count,
        active_listings: Listing.available.published.count,
        total_commission_paid: CommissionPayment.where(status: "paid").sum(:amount).to_f,
        monthly_revenue: CommissionPayment.where(status: "paid")
          .where("paid_at >= ?", Time.current.beginning_of_month)
          .sum(:amount).to_f
      }
    end

    field :flagged_listings, [ Types::Objects::FlaggedListingType ], null: false

    def flagged_listings
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user&.admin?

      FlaggedListing.unresolved.includes(:listing, :reporter)
    end
  end
end
