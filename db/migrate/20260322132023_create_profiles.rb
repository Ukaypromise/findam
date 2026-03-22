class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      # STI column
      t.string :type, null: false

      # Foreign key to users
      t.references :user, null: false, foreign_key: true, index: true

      # Common fields (shared by IecProfile and StudentProfile)
      t.string :full_name

      # IEC-specific fields
      t.string :location
      t.text :short_bio

      t.timestamps
    end

    # Index on type for STI queries
    add_index :profiles, :type
  end
end
