# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Auth
    field :user_registration, mutation: Mutations::UserRegistration, authenticate: false
    field :complete_onboarding, mutation: Mutations::CompleteOnboarding

    # Listings
    field :create_listing, mutation: Mutations::CreateListing
    field :update_listing, mutation: Mutations::UpdateListing
    field :delete_listing, mutation: Mutations::DeleteListing
    field :toggle_listing_availability, mutation: Mutations::ToggleListingAvailability

    # Messaging
    field :send_message, mutation: Mutations::SendMessage
    field :mark_messages_read, mutation: Mutations::MarkMessagesRead

    # Inspections
    field :create_inspection_slot, mutation: Mutations::CreateInspectionSlot
    field :book_inspection, mutation: Mutations::BookInspection
    field :confirm_inspection, mutation: Mutations::ConfirmInspection
    field :cancel_inspection, mutation: Mutations::CancelInspection

    # Payments
    field :initiate_payment, mutation: Mutations::InitiatePayment
    field :confirm_rental_agreement, mutation: Mutations::ConfirmRentalAgreement

    # Admin
    field :approve_user, mutation: Mutations::ApproveUser
    field :reject_user, mutation: Mutations::RejectUser
    field :suspend_user, mutation: Mutations::SuspendUser
    field :verify_landlord_nin, mutation: Mutations::VerifyLandlordNin
    field :certify_landlord, mutation: Mutations::CertifyLandlord
  end
end
