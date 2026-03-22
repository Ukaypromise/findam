module Types
  class Enums::ListingStatusEnumType < Types::BaseEnum
    description "Listing status options"

    value "DRAFT", value: "draft"
    value "PUBLISHED", value: "published"
    value "RENTED", value: "rented"
    value "REMOVED", value: "removed"
  end
end
