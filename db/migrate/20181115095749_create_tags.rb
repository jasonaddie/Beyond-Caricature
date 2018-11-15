class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Tag.create_translation_table! :name => :string
      end

      dir.down do
        Tag.drop_translation_table!
      end
    end

    add_index :tag_translations, :name
  end
end
