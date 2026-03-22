class AddSuspensionReasonToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :suspension_reason, :text
  end
end
