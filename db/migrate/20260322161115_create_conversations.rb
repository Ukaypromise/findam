class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :tenant, null: false, foreign_key: { to_table: :users }
      t.references :landlord, null: false, foreign_key: { to_table: :users }
      t.references :listing, null: false, foreign_key: true
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :conversations, [ :tenant_id, :landlord_id, :listing_id ], unique: true, name: "index_conversations_uniqueness"
  end
end
