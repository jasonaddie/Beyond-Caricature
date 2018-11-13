class CreatePublicationLanguages < ActiveRecord::Migration[5.2]
  def change
    create_table :publication_languages do |t|
      t.string :language
      t.boolean :is_active, default: false

      t.timestamps
    end

    add_index :publication_languages, :is_active
    add_index :publication_languages, :language
  end
end
