class CreateResearches < ActiveRecord::Migration[5.2]
  def change
    create_table :researches do |t|
      t.date :date_publish
      t.boolean :is_public

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Research.create_translation_table! :title => :string, :summary => :text, :text => :text
      end

      dir.down do
        Research.drop_translation_table!
      end
    end

    add_index :research_translations, :title
    add_index :researches, :is_public
    add_index :researches, :date_publish
  end
end
