class RoleSlugs < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :slug, :string
    add_index :roles, :slug, :unique => true
    add_column :role_translations, :slug, :string
    add_index :role_translations, :slug

    # populate data
    puts "- creating slugs"
    reversible do |dir|
      dir.up do
        Role.find_each(&:save)
      end

      dir.down do
        # do nothing
      end
    end
  end
end
