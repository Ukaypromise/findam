module Types
  class Objects::MessageType < Types::BaseObject
    field :id, ID, null: false
    field :conversation_id, Integer, null: false
    field :sender_id, Integer, null: false
    field :sender_type, String, null: false
    field :body, String, null: false
    field :read_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
