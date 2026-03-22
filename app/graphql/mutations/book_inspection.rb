module Mutations
  class BookInspection < BaseMutation
    description "Book an inspection slot (tenant only)"

    argument :slot_id, ID, required: true
    argument :listing_id, ID, required: true

    field :inspection_booking, Types::Objects::InspectionBookingType, null: true
    field :errors, [ String ], null: false

    def resolve(slot_id:, listing_id:)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user
      raise GraphQL::ExecutionError, "Only tenants can book inspections" unless current_user.tenant?

      listing = Listing.find(listing_id)
      slot = InspectionSlot.find(slot_id)

      raise GraphQL::ExecutionError, "Slot is already booked" if slot.is_booked
      raise GraphQL::ExecutionError, "Slot is in the past" if slot.starts_at <= Time.current

      booking = nil

      ActiveRecord::Base.transaction do
        slot.update!(is_booked: true)

        booking = InspectionBooking.create!(
          tenant: current_user,
          landlord_id: listing.landlord_id,
          listing: listing,
          inspection_slot: slot
        )
      end

      FindamSchema.subscriptions.trigger(
        :inspection_status_changed,
        { booking_id: booking.id },
        booking
      )

      { inspection_booking: booking, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { inspection_booking: nil, errors: e.record.errors.full_messages }
    end
  end
end
