class CreatePeople < ActiveRecord::Migration[5.2]
  def change

    create_table :people do |t|
      t.integer :roles, array: true, default: [], null: false
      t.date :date_birth
      t.date :date_death
      t.boolean :is_public, default: false
      t.string :image_uid
      t.string :slug

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Person.create_translation_table! :name => :string,
          :bio => :text,
          :is_public => {type: :boolean, default: false},
          :date_publish => :date,
          :slug => :string
      end

      dir.down do
        Person.drop_translation_table!
      end
    end

    add_index :person_translations, :name
    add_index :person_translations, :slug
    add_index :person_translations, :is_public
    add_index :person_translations, :date_publish
    add_index :people, :roles
    add_index :people, :is_public
    add_index :people, :date_birth
    add_index :people, :date_death
    add_index :people, :slug, :unique => true

  end
end
