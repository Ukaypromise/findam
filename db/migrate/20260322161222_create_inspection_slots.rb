class CreateInspectionSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :inspection_slots do |t|
      t.references :landlord, null: false, foreign_key: { to_table: :users }
      t.references :listing, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.boolean :is_booked, default: false, null: false

      t.timestamps
    end

    add_index :inspection_slots, [:listing_id, :is_booked]
  end
end
