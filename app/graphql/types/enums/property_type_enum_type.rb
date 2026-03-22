module Types
  class Enums::PropertyTypeEnumType < Types::BaseEnum
    description "Property type options"

    value "FLAT", value: "flat"
    value "DUPLEX", value: "duplex"
    value "BUNGALOW", value: "bungalow"
    value "SELF_CONTAIN", value: "self_contain"
    value "ROOM_AND_PARLOUR", value: "room_and_parlour"
  end
end
