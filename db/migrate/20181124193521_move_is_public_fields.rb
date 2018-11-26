class MoveIsPublicFields < ActiveRecord::Migration[5.2]
  def up
    add_column :news_translations, :is_public, :boolean, default: false
    add_column :news_translations, :date_publish, :date
    add_index :news_translations, :is_public
    add_index :news_translations, :date_publish

    remove_index :news, :is_public
    remove_index :news, :date_publish
    remove_column :news, :is_public
    remove_column :news, :date_publish
  end

  def down
    add_column :news, :is_public, :boolean, default: false
    add_column :news, :date_publish, :date
    add_index :news, :is_public
    add_index :news, :date_publish

    remove_index :news_translations, :is_public
    remove_index :news_translations, :date_publish
    remove_column :news_translations, :is_public
    remove_column :news_translations, :date_publish
  end
end
