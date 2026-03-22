# frozen_string_literal: true

module Mutations
  class UserRegistration < BaseMutation
    description "Register a new user (IEC or Student)"

    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true
    argument :type, Types::Enums::UserTypeEnumType, required: true
    # argument :confirm_url, String, required: true

    field :authenticatable, Types::Objects::UserType, null: true
    field :credentials, GraphqlDevise::Types::CredentialType, null: true

    def resolve(email:, password:, password_confirmation:, type:, confirm_url: nil)
      user = User.new(email: email, password: password, password_confirmation: password_confirmation, type: type)

      raise GraphQL::ExecutionError.new "Error registering user", extensions: user.errors.to_hash unless user.save

      # Todo: We may bring back confirmation instructions
      # user.send_confirmation_instructions(redirect_url: confirm_url)

      auth_headers = user.create_new_auth_token

      {
        authenticatable: user,
        credentials: auth_headers # Todo: We can set this to nil if Feras does not approves credentials returning the user object only
      }
    end
  end
end
