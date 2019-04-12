class RoleIsIllustrator < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :is_illustrator, :boolean, default: false
    add_index :roles, :is_illustrator

    reversible do |dir|
      dir.up do
        # update existing role
        Role.where(name: 'Illustrator').update_all(is_illustrator: true)
      end
    end
  end
end
