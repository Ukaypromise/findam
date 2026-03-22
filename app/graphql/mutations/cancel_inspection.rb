module Mutations
  class CancelInspection < BaseMutation
    description "Cancel an inspection booking (either party)"

    argument :booking_id, ID, required: true
    argument :reason, String, required: false

    field :inspection_booking, Types::Objects::InspectionBookingType, null: true
    field :errors, [String], null: false

    def resolve(booking_id:, reason: nil)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      booking = InspectionBooking.find(booking_id)

      unless booking.tenant_id == current_user.id || booking.landlord_id == current_user.id
        raise GraphQL::ExecutionError, "Not authorized"
      end

      cancelled_by = current_user.landlord? ? "landlord" : "tenant"

      booking.cancelled_by = cancelled_by
      booking.cancellation_reason = reason

      unless booking.cancel
        raise GraphQL::ExecutionError, "Cannot cancel booking from current status: #{booking.status}"
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
