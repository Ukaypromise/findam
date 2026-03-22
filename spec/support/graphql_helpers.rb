module GraphqlHelpers
  def execute_graphql(query:, variables: {}, context: {})
    FindamSchema.execute(
      query,
      variables: variables,
      context: context
    )
  end

  def graphql_context(user)
    { current_resource: user }
  end
end

RSpec.configure do |config|
  config.include GraphqlHelpers
end
