class MoveRoleField < ActiveRecord::Migration[5.2]
  def up
    add_column :person_roles, :role, :integer
    add_index :person_roles, :role

    remove_index :people, :roles
    remove_column :people, :roles
  end

  def down
    add_column :people, :roles, :integer, array: true, default: [], null: false
    add_index :people, :roles

    remove_index :person_roles, :role
    remove_column :person_roles, :role
  end
end
