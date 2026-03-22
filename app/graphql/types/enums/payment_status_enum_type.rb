module Types
  class Enums::PaymentStatusEnumType < Types::BaseEnum
    description "Payment status options"

    value "PENDING", value: "pending"
    value "PAID", value: "paid"
    value "FAILED", value: "failed"
    value "REFUNDED", value: "refunded"
  end
end
