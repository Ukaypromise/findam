# frozen_string_literal: true

module Types
  class Objects::UserType < Types::BaseObject
    field :id, ID, null: false
    field :provider, String, null: false
    field :uid, String, null: false
    field :encrypted_password, String, null: false
    field :reset_password_token, String
    field :reset_password_sent_at, GraphQL::Types::ISO8601DateTime
    field :allow_password_change, Boolean
    field :remember_created_at, GraphQL::Types::ISO8601DateTime
    field :confirmation_token, String
    field :confirmed_at, GraphQL::Types::ISO8601DateTime
    field :confirmation_sent_at, GraphQL::Types::ISO8601DateTime
    field :unconfirmed_email, String
    field :name, String
    field :nickname, String
    field :image, String
    field :email, String
    field :tokens, GraphQL::Types::JSON
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :type, String
    field :onboarding_completed, Boolean, null: false
    field :onboarding_completed_at, GraphQL::Types::ISO8601DateTime
    field :approval_status, String, null: false
    field :approved_at, GraphQL::Types::ISO8601DateTime
    field :rejected_at, GraphQL::Types::ISO8601DateTime
    field :rejection_reason, String

    field :landlord_profile, Types::Objects::LandlordProfileType, null: true
    field :tenant_profile, Types::Objects::TenantProfileType, null: true

    def landlord_profile
      object.landlord? ? object.landlord_profile : nil
    end

    def tenant_profile
      object.tenant? ? object.tenant_profile : nil
    end
  end
end
