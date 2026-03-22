class CreateCommissionPayments < ActiveRecord::Migration[8.0]
  def change
    create_table :commission_payments do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: { to_table: :users }
      t.references :landlord, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 12, scale: 2
      t.decimal :tenant_percentage, precision: 5, scale: 2
      t.decimal :landlord_percentage, precision: 5, scale: 2
      t.string :status, default: "pending", null: false
      t.string :paystack_reference
      t.datetime :paid_at
      t.string :payment_url
      t.datetime :landlord_confirmed_at
      t.datetime :tenant_confirmed_at

      t.timestamps
    end

    add_index :commission_payments, :status
    add_index :commission_payments, :paystack_reference, unique: true
  end
end
