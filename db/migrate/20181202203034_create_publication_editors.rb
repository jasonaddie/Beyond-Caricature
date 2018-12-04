class CreatePublicationEditors < ActiveRecord::Migration[5.2]
  def change
    create_table :publication_editors do |t|
      t.references :publication
      t.integer :year_start
      t.integer :year_end

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        PublicationEditor.create_translation_table! :editor => :string, :publisher => :string
      end

      dir.down do
        PublicationEditor.drop_translation_table!
      end
    end

  end
end
