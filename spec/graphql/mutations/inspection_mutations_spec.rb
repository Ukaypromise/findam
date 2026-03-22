require 'rails_helper'

RSpec.describe "Inspection Mutations", type: :request do
  let(:landlord) { create(:landlord, :approved) }
  let(:tenant) { create(:tenant_user, :approved) }
  let(:listing) { create(:listing, landlord: landlord) }

  describe Mutations::CreateInspectionSlot do
    let(:mutation) do
      <<~GQL
        mutation CreateInspectionSlot($input: CreateInspectionSlotInput!) {
          createInspectionSlot(input: $input) {
            inspectionSlot {
              id
              startsAt
              endsAt
              isBooked
            }
            errors
          }
        }
      GQL
    end

    context "when landlord creates slot" do
      it "creates successfully" do
        variables = {
          input: {
            listingId: listing.id.to_s,
            startsAt: 1.day.from_now.iso8601,
            endsAt: (1.day.from_now + 2.hours).iso8601
          }
        }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

        data = result.dig("data", "createInspectionSlot")
        expect(data["errors"]).to be_empty
        expect(data["inspectionSlot"]["isBooked"]).to be false
      end
    end

    context "when tenant tries to create slot" do
      it "raises error" do
        variables = {
          input: {
            listingId: listing.id.to_s,
            startsAt: 1.day.from_now.iso8601,
            endsAt: (1.day.from_now + 2.hours).iso8601
          }
        }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        expect(result["errors"].first["message"]).to eq("Only landlords can create inspection slots")
      end
    end

    context "when not authenticated" do
      it "raises error" do
        variables = {
          input: {
            listingId: listing.id.to_s,
            startsAt: 1.day.from_now.iso8601,
            endsAt: (1.day.from_now + 2.hours).iso8601
          }
        }
        result = execute_graphql(query: mutation, variables: variables, context: {})

        expect(result["errors"].first["message"]).to include("requires authentication")
      end
    end
  end

  describe Mutations::BookInspection do
    let(:slot) { create(:inspection_slot, landlord: landlord, listing: listing) }

    let(:mutation) do
      <<~GQL
        mutation BookInspection($input: BookInspectionInput!) {
          bookInspection(input: $input) {
            inspectionBooking {
              id
              status
            }
            errors
          }
        }
      GQL
    end

    context "when tenant books inspection" do
      it "creates booking and marks slot as booked" do
        variables = { input: { slotId: slot.id.to_s, listingId: listing.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        data = result.dig("data", "bookInspection")
        expect(data["errors"]).to be_empty
        expect(data["inspectionBooking"]["status"]).to eq("pending")
        expect(slot.reload.is_booked).to be true
      end
    end

    context "when landlord tries to book" do
      it "raises error" do
        variables = { input: { slotId: slot.id.to_s, listingId: listing.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

        expect(result["errors"].first["message"]).to eq("Only tenants can book inspections")
      end
    end

    context "when not authenticated" do
      it "raises error" do
        variables = { input: { slotId: slot.id.to_s, listingId: listing.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: {})

        expect(result["errors"].first["message"]).to include("requires authentication")
      end
    end
  end

  describe Mutations::ConfirmInspection do
    let(:slot) { create(:inspection_slot, landlord: landlord, listing: listing, is_booked: true) }
    let(:booking) { create(:inspection_booking, tenant: tenant, landlord: landlord, listing: listing, inspection_slot: slot) }

    let(:mutation) do
      <<~GQL
        mutation ConfirmInspection($input: ConfirmInspectionInput!) {
          confirmInspection(input: $input) {
            inspectionBooking {
              id
              status
              confirmedAt
            }
            errors
          }
        }
      GQL
    end

    context "when landlord confirms" do
      it "sets status to confirmed" do
        variables = { input: { bookingId: booking.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

        data = result.dig("data", "confirmInspection")
        expect(data["errors"]).to be_empty
        expect(data["inspectionBooking"]["status"]).to eq("confirmed")
        expect(data["inspectionBooking"]["confirmedAt"]).not_to be_nil
      end
    end

    context "when tenant tries to confirm" do
      it "raises error" do
        variables = { input: { bookingId: booking.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        expect(result["errors"].first["message"]).to eq("Only landlords can confirm inspections")
      end
    end
  end

  describe Mutations::CancelInspection do
    let(:slot) { create(:inspection_slot, landlord: landlord, listing: listing, is_booked: true) }
    let(:booking) { create(:inspection_booking, tenant: tenant, landlord: landlord, listing: listing, inspection_slot: slot) }

    let(:mutation) do
      <<~GQL
        mutation CancelInspection($input: CancelInspectionInput!) {
          cancelInspection(input: $input) {
            inspectionBooking {
              id
              status
              cancelledBy
              cancellationReason
            }
            errors
          }
        }
      GQL
    end

    context "when tenant cancels" do
      it "sets status to cancelled and frees slot" do
        variables = { input: { bookingId: booking.id.to_s, reason: "Changed plans" } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        data = result.dig("data", "cancelInspection")
        expect(data["errors"]).to be_empty
        expect(data["inspectionBooking"]["status"]).to eq("cancelled")
        expect(data["inspectionBooking"]["cancelledBy"]).to eq("tenant")
        expect(slot.reload.is_booked).to be false
      end
    end

    context "when not authenticated" do
      it "raises error" do
        variables = { input: { bookingId: booking.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: {})

        expect(result["errors"].first["message"]).to include("requires authentication")
      end
    end
  end
end
