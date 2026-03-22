require 'rails_helper'

RSpec.describe "Admin Mutations", type: :request do
  let(:admin) { create(:admin_user) }
  let(:landlord) { create(:landlord, :submitted) }
  let(:tenant) { create(:tenant_user) }

  describe Mutations::ApproveUser do
    let(:mutation) do
      <<~GQL
        mutation ApproveUser($input: ApproveUserInput!) {
          approveUser(input: $input) {
            user {
              id
              approvalStatus
            }
            errors
          }
        }
      GQL
    end

    context "when admin approves" do
      it "sets approval_status to approved" do
        variables = { input: { userId: landlord.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(admin))

        data = result.dig("data", "approveUser")
        expect(data["errors"]).to be_empty
        expect(data["user"]["approvalStatus"]).to eq("approved")
      end
    end

    context "when non-admin tries" do
      it "raises not authorized" do
        variables = { input: { userId: landlord.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        expect(result["errors"].first["message"]).to eq("Not authorized")
      end
    end

    context "when not authenticated" do
      it "raises not authorized" do
        variables = { input: { userId: landlord.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: {})

        expect(result["errors"].first["message"]).to include("requires authentication")
      end
    end
  end

  describe Mutations::RejectUser do
    let(:mutation) do
      <<~GQL
        mutation RejectUser($input: RejectUserInput!) {
          rejectUser(input: $input) {
            user {
              id
              approvalStatus
              rejectionReason
            }
            errors
          }
        }
      GQL
    end

    context "when admin rejects" do
      it "sets approval_status to rejected with reason" do
        variables = { input: { userId: landlord.id.to_s, reason: "Incomplete documents" } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(admin))

        data = result.dig("data", "rejectUser")
        expect(data["errors"]).to be_empty
        expect(data["user"]["approvalStatus"]).to eq("rejected")
        expect(data["user"]["rejectionReason"]).to eq("Incomplete documents")
      end
    end

    context "when non-admin tries" do
      it "raises not authorized" do
        variables = { input: { userId: landlord.id.to_s, reason: "Bad" } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        expect(result["errors"].first["message"]).to eq("Not authorized")
      end
    end
  end

  describe Mutations::SuspendUser do
    let(:mutation) do
      <<~GQL
        mutation SuspendUser($input: SuspendUserInput!) {
          suspendUser(input: $input) {
            user {
              id
              approvalStatus
            }
            errors
          }
        }
      GQL
    end

    context "when admin suspends" do
      it "sets approval_status to suspended" do
        variables = { input: { userId: landlord.id.to_s, reason: "Fraudulent activity" } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(admin))

        data = result.dig("data", "suspendUser")
        expect(data["errors"]).to be_empty
        expect(data["user"]["approvalStatus"]).to eq("suspended")
      end
    end

    context "when non-admin tries" do
      it "raises not authorized" do
        variables = { input: { userId: landlord.id.to_s, reason: "test" } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        expect(result["errors"].first["message"]).to eq("Not authorized")
      end
    end
  end

  describe Mutations::VerifyLandlordNin do
    let(:approved_landlord) do
      l = create(:landlord, :approved)
      l.profile.update_column(:full_name, "Test Landlord")
      l
    end

    let(:mutation) do
      <<~GQL
        mutation VerifyLandlordNin($input: VerifyLandlordNinInput!) {
          verifyLandlordNin(input: $input) {
            landlordProfile {
              id
              isNinVerified
            }
            errors
          }
        }
      GQL
    end

    context "when admin verifies" do
      it "sets nin_verified to true" do
        variables = { input: { landlordId: approved_landlord.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(admin))

        data = result.dig("data", "verifyLandlordNin")
        expect(data["errors"]).to be_empty
        expect(data["landlordProfile"]["isNinVerified"]).to be true
      end
    end

    context "when non-admin tries" do
      it "raises not authorized" do
        variables = { input: { landlordId: approved_landlord.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        expect(result["errors"].first["message"]).to eq("Not authorized")
      end
    end
  end

  describe Mutations::CertifyLandlord do
    let(:approved_landlord) do
      l = create(:landlord, :approved)
      l.profile.update_column(:full_name, "Test Landlord")
      l
    end

    let(:mutation) do
      <<~GQL
        mutation CertifyLandlord($input: CertifyLandlordInput!) {
          certifyLandlord(input: $input) {
            landlordProfile {
              id
              isCertified
            }
            errors
          }
        }
      GQL
    end

    context "when admin certifies" do
      it "sets certified to true" do
        variables = { input: { landlordId: approved_landlord.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(admin))

        data = result.dig("data", "certifyLandlord")
        expect(data["errors"]).to be_empty
        expect(data["landlordProfile"]["isCertified"]).to be true
      end
    end

    context "when non-admin tries" do
      it "raises not authorized" do
        variables = { input: { landlordId: approved_landlord.id.to_s } }
        result = execute_graphql(query: mutation, variables: variables, context: graphql_context(tenant))

        expect(result["errors"].first["message"]).to eq("Not authorized")
      end
    end
  end
end
