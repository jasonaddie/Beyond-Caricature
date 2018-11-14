class CreateIllustrators < ActiveRecord::Migration[5.2]
  def change
    create_table :illustrators do |t|
      t.date :date_birth
      t.date :date_death
      t.boolean :is_public, default: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Illustrator.create_translation_table! :name => :string, :bio => :text
      end

      dir.down do
        Illustrator.drop_translation_table!
      end
    end

    add_index :illustrator_translations, :name
    add_index :illustrators, :is_public
    add_index :illustrators, :date_birth
    add_index :illustrators, :date_death
  end
end
