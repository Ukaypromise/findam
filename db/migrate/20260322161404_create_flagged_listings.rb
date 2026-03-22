class CreateFlaggedListings < ActiveRecord::Migration[8.0]
  def change
    create_table :flagged_listings do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.string :reason, null: false
      t.boolean :resolved, default: false, null: false

      t.timestamps
    end

    add_index :flagged_listings, :resolved
  end
end
