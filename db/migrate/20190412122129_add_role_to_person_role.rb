class AddRoleToPersonRole < ActiveRecord::Migration[5.2]
  def up
    # rename old role field
    rename_column :person_roles, :role, :role_old

    # create reference
    add_reference :person_roles, :role, index: true

    # create role records and update person role records to have this id
    %w(Illustrator Editor Publisher Writer Printer Financier Official Subject).each_with_index do |role, i|
      r = Role.create(name: role)

      PersonRole.where(role_old: (i+1)).update_all(role_id: r.id)
    end
  end

  def down
    Role.destroy_all
    remove_reference :person_roles, :role, index: true
    rename_column :person_roles, :role_old, :role
  end
end
