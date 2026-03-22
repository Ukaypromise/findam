class AddOnboardingAndApprovalFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :onboarding_completed, :boolean, default: false, null: false
    add_column :users, :onboarding_completed_at, :datetime, null: true
    add_column :users, :approval_status, :string, default: 'pending', null: false
    add_column :users, :approved_at, :datetime, null: true
    add_column :users, :rejected_at, :datetime, null: true
    add_column :users, :rejection_reason, :text, null: true

    add_index :users, :approval_status
    add_index :users, :onboarding_completed
  end
end
