require 'rails_helper'

RSpec.describe "Payment Mutations", type: :request do
  let(:landlord) { create(:landlord, :approved) }
  let(:tenant) { create(:tenant_user, :approved) }
  let(:listing) { create(:listing, landlord: landlord) }

  describe Mutations::InitiatePayment do
    let(:mutation) do
      <<~GQL
        mutation InitiatePayment($input: InitiatePaymentInput!) {
          initiatePayment(input: $input) {
            commissionPayment {
              id
              status
              amount
              paystackReference
            }
            paymentUrl
            errors
          }
        }
      GQL
    end

    context "when tenant initiates payment" do
      it "creates commission payment and returns payment URL" do
        variables = { input: { listingId: listing.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        data = result.dig("data", "initiatePayment")
        expect(data["errors"]).to be_empty
        expect(data["commissionPayment"]["status"]).to eq("pending")
        expect(data["paymentUrl"]).to be_present
      end
    end

    context "when landlord tries to initiate" do
      it "raises error" do
        variables = { input: { listingId: listing.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

        expect(result["errors"].first["message"]).to eq("Only tenants can initiate payments")
      end
    end

    context "when not authenticated" do
      it "raises error" do
        variables = { input: { listingId: listing.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: {})

        expect(result["errors"].first["message"]).to include("requires authentication")
      end
    end
  end

  describe Mutations::ConfirmRentalAgreement do
    let(:mutation) do
      <<~GQL
        mutation ConfirmRentalAgreement($input: ConfirmRentalAgreementInput!) {
          confirmRentalAgreement(input: $input) {
            commissionPayment {
              id
              landlordConfirmedAt
              tenantConfirmedAt
            }
            paymentUrl
            errors
          }
        }
      GQL
    end

    context "when landlord confirms" do
      it "records landlord confirmation" do
        variables = { input: { listingId: listing.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

        data = result.dig("data", "confirmRentalAgreement")
        expect(data["errors"]).to be_empty
        expect(data["commissionPayment"]["landlordConfirmedAt"]).to be_present
      end
    end

    context "when not authenticated" do
      it "raises error" do
        variables = { input: { listingId: listing.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: {})

        expect(result["errors"].first["message"]).to include("requires authentication")
      end
    end
  end
end
