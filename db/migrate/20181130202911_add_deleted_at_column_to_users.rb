class AddDeletedAtColumnToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :deleted_at, :datetime

    remove_index :users, :is_active
    remove_column :users, :is_active
  end
  def down
    remove_column :users, :deleted_at, :datetime

    add_column :users, :is_active, :boolean, default: true
    add_index :users, :is_active
  end
end
