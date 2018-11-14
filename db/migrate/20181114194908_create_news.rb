class CreateNews < ActiveRecord::Migration[5.2]
  def change
    create_table :news do |t|
      t.date :date_publish
      t.boolean :is_public

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        News.create_translation_table! :title => :string, :summary => :text, :text => :text
      end

      dir.down do
        News.drop_translation_table!
      end
    end

    add_index :news_translations, :title
    add_index :news, :is_public
    add_index :news, :date_publish
  end
end
