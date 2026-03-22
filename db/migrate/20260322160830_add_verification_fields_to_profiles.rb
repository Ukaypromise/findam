class AddVerificationFieldsToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :phone_number, :string
    add_column :profiles, :nin_verified, :boolean, default: false, null: false
    add_column :profiles, :nin_verified_at, :datetime
    add_column :profiles, :certified, :boolean, default: false, null: false
    add_column :profiles, :certified_at, :datetime
    add_column :profiles, :top_landlord, :boolean, default: false, null: false
    add_column :profiles, :top_landlord_recalculated_at, :datetime
  end
end
