class CreatePublications < ActiveRecord::Migration[5.2]
  def change
    create_table :publications do |t|
      t.integer :publication_type, default: 0
      t.belongs_to :publication_language
      t.boolean :is_public, default: false
      t.date :date_publish
      t.integer :year_publication_start
      t.integer :year_publication_end
      t.date :date_publication

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Publication.create_translation_table! :title => :string, :about => :text, :editor => :string, :publisher => :string, :writer => :string
      end

      dir.down do
        Publication.drop_translation_table!
      end
    end

    add_index :publication_translations, :title
    add_index :publications, :publication_type
    add_index :publications, :is_public
    add_index :publications, :date_publish
    add_index :publications, :year_publication_start
    add_index :publications, :year_publication_end
    add_index :publications, :date_publication
  end
end
