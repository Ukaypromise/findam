module Types
  class Enums::InspectionStatusEnumType < Types::BaseEnum
    description "Inspection booking status options"

    value "PENDING", value: "pending"
    value "CONFIRMED", value: "confirmed"
    value "CANCELLED", value: "cancelled"
    value "COMPLETED", value: "completed"
  end
end
