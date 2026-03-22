class AddTypeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :type, :string, null: true
    add_index :users, :type
  end
end
