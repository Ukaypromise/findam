require 'rails_helper'

RSpec.describe Mutations::DeleteListing, type: :request do
  let(:landlord) { create(:landlord, :approved) }
  let(:listing) { create(:listing, landlord: landlord) }

  let(:mutation) do
    <<~GQL
      mutation DeleteListing($input: DeleteListingInput!) {
        deleteListing(input: $input) {
          listing {
            id
            status
          }
          errors
        }
      }
    GQL
  end

  context "when owner deletes" do
    it "soft deletes by setting status to removed" do
      variables = { input: { id: listing.id.to_s } }
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

      data = result.dig("data", "deleteListing")
      expect(data["errors"]).to be_empty
      expect(data["listing"]["status"]).to eq("removed")
    end
  end

  context "when not owner" do
    let(:other_landlord) { create(:landlord, :approved) }

    it "raises not authorized" do
      variables = { input: { id: listing.id.to_s } }
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(other_landlord))

      expect(result["errors"].first["message"]).to eq("Not authorized")
    end
  end

  context "when not authenticated" do
    it "raises not authorized" do
      variables = { input: { id: listing.id.to_s } }
      result = execute_graphql(query: mutation, variables: variables, context: {})

      expect(result["errors"].first["message"]).to include("requires authentication")
    end
  end
end
