class CreateIllustrations < ActiveRecord::Migration[5.2]
  def change
    create_table :illustrations do |t|
      t.references :illustrator, foreign_key: true
      t.boolean :is_public, default: false
      t.date :date_publish

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Illustration.create_translation_table! :title => :string, :context => :text
      end

      dir.down do
        Illustration.drop_translation_table!
      end
    end

    add_index :illustration_translations, :title
    add_index :illustrations, :is_public
    add_index :illustrations, :date_publish
  end
end
