# frozen_string_literal: true

class FindamSchema < GraphQL::Schema
  use GraphqlDevise::SchemaPlugin.new(
    query:            Types::QueryType,
    mutation:         Types::MutationType,
    resource_loaders: [
      GraphqlDevise::ResourceLoader.new(User, only: [:login, :logout, :register, :update_password_with_token, :send_password_reset_with_token, :resend_confirmation_with_token, :confirm_registration_with_token])
    ]
  )

  mutation(Types::MutationType)
  query(Types::QueryType)
  subscription(Types::SubscriptionType)
  use GraphQL::Subscriptions::ActionCableSubscriptions


  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    # if err.is_a?(GraphQL::InvalidNullError)
    #   # report to your bug tracker here
    #   return nil
    # end
    super
  end

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    # TODO: Implement this method
    # to return the correct GraphQL object type for `obj`
    raise(GraphQL::RequiredImplementationMissingError)
  end

  # Limit the size of incoming queries:
  max_query_string_tokens(5000)

  # Stop validating when it encounters this many errors:
  validate_max_errors(100)

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    object.to_gid_param
  end

  # Given a string UUID, find the object
  def self.object_from_id(global_id, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    GlobalID.find(global_id)
  end

  rescue_from(ActiveRecord::RecordInvalid) do |exception|
    model = exception.record.model_name.human
    raise GraphQL::ExecutionError.new(
      "#{model} validation failed",
      extensions: {
        code: "VALIDATION_ERROR",
        details: exception.record.errors.messages
      }
    )
  end

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    model = exception.model&.underscore&.humanize || "Record"
    raise GraphQL::ExecutionError.new(
      "#{model} not found",
      extensions: { code: "NOT_FOUND" }
    )
  end
end
