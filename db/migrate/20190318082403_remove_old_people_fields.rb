class RemoveOldPeopleFields < ActiveRecord::Migration[5.2]
  def up
    # illustration - illustrator_id
    remove_index :illustrations, :illustrator_id
    remove_column :illustrations, :illustrator_id

    # publication - editor, publisher, writer
    remove_column :publication_translations, :editor
    remove_column :publication_translations, :publisher
    remove_column :publication_translations, :writer

    # publication editors - editor, publisher
    remove_column :publication_editor_translations, :editor
    remove_column :publication_editor_translations, :publisher

  end

  def down
    # illustration - illustrator_id
    add_column :illustrations, :illustrator_id, :bigint
    add_index :illustrations, :illustrator_id

    # publication - editor, publisher, writer
    add_column :publication_translations, :editor, :string
    add_column :publication_translations, :publisher, :string
    add_column :publication_translations, :writer, :string

    # publication editors - editor, publisher
    add_column :publication_editor_translations, :editor, :string
    add_column :publication_editor_translations, :publisher, :string

  end
end
