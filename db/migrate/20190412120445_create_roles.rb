class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Role.create_translation_table! name: :string
      end

      dir.down do
        Role.drop_translation_table!
      end
    end

    add_index :role_translations, :name
  end
end
