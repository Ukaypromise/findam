class CreateInspectionBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :inspection_bookings do |t|
      t.references :tenant, null: false, foreign_key: { to_table: :users }
      t.references :landlord, null: false, foreign_key: { to_table: :users }
      t.references :listing, null: false, foreign_key: true
      t.references :inspection_slot, null: false, foreign_key: true
      t.string :status, default: "pending", null: false
      t.string :cancelled_by
      t.string :cancellation_reason
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :inspection_bookings, :status
  end
end
