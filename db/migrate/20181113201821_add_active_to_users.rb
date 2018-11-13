class AddActiveToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_active, :boolean, default: true
    add_index :users, :is_active
  end
end
