# frozen_string_literal: true

module Types
  class Enums::UserTypeEnumType < Types::BaseEnum
    description "User type options"

    value "LANDLORD", value: "Landlord"
    value "TENANT", value: "Tenant"
    value "ADMIN", value: "Admin"
  end
end
