class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, polymorphic: true
      t.text :body, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, :read_at
  end
end
