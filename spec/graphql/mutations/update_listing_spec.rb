require 'rails_helper'

RSpec.describe Mutations::UpdateListing, type: :request do
  let(:landlord) { create(:landlord, :approved) }
  let(:listing) { create(:listing, landlord: landlord) }

  let(:mutation) do
    <<~GQL
      mutation UpdateListing($input: UpdateListingInput!) {
        updateListing(input: $input) {
          listing {
            id
            title
            price
          }
          errors
        }
      }
    GQL
  end

  context "when owner updates listing" do
    it "updates successfully" do
      variables = { input: { id: listing.id.to_s, title: "Updated Title", price: 2000000.0 } }
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

      data = result.dig("data", "updateListing")
      expect(data["errors"]).to be_empty
      expect(data["listing"]["title"]).to eq("Updated Title")
    end
  end

  context "when non-owner tries to update" do
    let(:other_landlord) { create(:landlord, :approved) }

    it "raises not authorized" do
      variables = { input: { id: listing.id.to_s, title: "Hacked" } }
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(other_landlord))

      expect(result["errors"].first["message"]).to eq("Not authorized")
    end
  end

  context "when not authenticated" do
    it "raises not authorized" do
      variables = { input: { id: listing.id.to_s, title: "Hacked" } }
      result = execute_graphql(query: mutation, variables: variables, context: {})

      expect(result["errors"].first["message"]).to include("requires authentication")
    end
  end
end
