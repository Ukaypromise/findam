class CreateListings < ActiveRecord::Migration[8.0]
  def change
    create_table :listings do |t|
      t.references :landlord, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.string :address, null: false
      t.string :city, null: false
      t.string :property_type, null: false
      t.integer :bedrooms
      t.integer :bathrooms
      t.boolean :is_available, default: true, null: false
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.string :status, default: "draft", null: false

      t.timestamps
    end

    add_index :listings, :city
    add_index :listings, :property_type
    add_index :listings, :status
    add_index :listings, :is_available
    add_index :listings, [:city, :is_available, :status]
  end
end
