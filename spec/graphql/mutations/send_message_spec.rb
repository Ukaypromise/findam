require 'rails_helper'

RSpec.describe Mutations::SendMessage, type: :request do
  let(:landlord) { create(:landlord, :approved) }
  let(:tenant) { create(:tenant_user, :approved) }
  let(:listing) { create(:listing, landlord: landlord) }

  let(:mutation) do
    <<~GQL
      mutation SendMessage($input: SendMessageInput!) {
        sendMessage(input: $input) {
          message {
            id
            body
            senderId
          }
          errors
        }
      }
    GQL
  end

  context "when tenant sends message to landlord" do
    it "creates message and conversation" do
      variables = { input: { recipientId: landlord.id.to_s, listingId: listing.id.to_s, body: "Is this still available?" } }
      result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

      data = result.dig("data", "sendMessage")
      expect(data["errors"]).to be_empty
      expect(data["message"]["body"]).to eq("Is this still available?")
      expect(Conversation.count).to eq(1)
    end
  end

  context "when not authenticated" do
    it "raises not authorized" do
      variables = { input: { recipientId: landlord.id.to_s, listingId: listing.id.to_s, body: "Hello" } }
      result = execute_graphql(query: mutation, variables: variables, context: {})

      expect(result["errors"].first["message"]).to include("requires authentication")
    end
  end
end
