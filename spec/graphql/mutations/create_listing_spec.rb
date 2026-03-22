require 'rails_helper'

RSpec.describe Mutations::CreateListing, type: :request do
  let(:mutation) do
    <<~GQL
      mutation CreateListing($input: CreateListingInput!) {
        createListing(input: $input) {
          listing {
            id
            title
            description
            price
            address
            city
            propertyType
            bedrooms
            bathrooms
            status
          }
          errors
        }
      }
    GQL
  end

  let(:variables) do
    {
      input: {
        title: "Beautiful Flat in Lekki",
        description: "Spacious 3 bedroom flat",
        price: 1500000.0,
        address: "12 Admiralty Way, Lekki",
        city: "Lagos",
        propertyType: "FLAT",
        bedrooms: 3,
        bathrooms: 2
      }
    }
  end

  context "when landlord is approved" do
    let(:landlord) { create(:landlord, :approved) }

    it "creates a listing successfully" do
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

      data = result.dig("data", "createListing")
      expect(data["errors"]).to be_empty
      expect(data["listing"]["title"]).to eq("Beautiful Flat in Lekki")
      expect(data["listing"]["price"]).to eq(1500000.0)
      expect(data["listing"]["propertyType"]).to eq("flat")
    end
  end

  context "when validation fails" do
    let(:landlord) { create(:landlord, :approved) }

    it "returns errors for missing fields" do
      variables[:input][:title] = ""
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

      data = result.dig("data", "createListing")
      expect(data["listing"]).to be_nil
      expect(data["errors"]).to include("Title can't be blank")
    end
  end

  context "when not authenticated" do
    it "raises an error" do
      result = execute_graphql(query: mutation, variables: variables, context: {})

      expect(result["errors"].first["message"]).to include("requires authentication")
    end
  end

  context "when landlord is not approved" do
    let(:landlord) { create(:landlord) }

    it "raises an error" do
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(landlord))

      expect(result["errors"].first["message"]).to eq("Landlord must be approved")
    end
  end

  context "when user is a tenant" do
    let(:tenant) { create(:tenant_user, :approved) }

    it "raises an error" do
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

      expect(result["errors"].first["message"]).to eq("Only landlords can create listings")
    end
  end
end
