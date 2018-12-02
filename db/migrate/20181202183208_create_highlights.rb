class CreateHighlights < ActiveRecord::Migration[5.2]
  def change
    create_table :highlights do |t|

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Highlight.create_translation_table! :title => :string, :summary => :text, :link => :string,
          :is_public => {:type => :boolean, :default => false},
          :date_publish => :date
      end

      dir.down do
        Highlight.drop_translation_table!
      end
    end

    add_index :highlight_translations, :title
    add_index :highlight_translations, :is_public
    add_index :highlight_translations, :date_publish
  end
end
