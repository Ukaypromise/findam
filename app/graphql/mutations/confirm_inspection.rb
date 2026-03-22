module Mutations
  class ConfirmInspection < BaseMutation
    description "Confirm an inspection booking (landlord only)"

    argument :booking_id, ID, required: true

    field :inspection_booking, Types::Objects::InspectionBookingType, null: true
    field :errors, [ String ], null: false

    def resolve(booking_id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user
      raise GraphQL::ExecutionError, "Only landlords can confirm inspections" unless current_user.landlord?

      booking = InspectionBooking.find(booking_id)
      raise GraphQL::ExecutionError, "Not authorized" unless booking.landlord_id == current_user.id

      unless booking.confirm
        raise GraphQL::ExecutionError, "Cannot confirm booking from current status: #{booking.status}"
      end

      FindamSchema.subscriptions.trigger(
        :inspection_status_changed,
        { booking_id: booking.id },
        booking
      )

      { inspection_booking: booking, errors: [] }
    end
  end
end
