class AddSlugColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :slug, :string
    add_index :publications, :slug, :unique => true
    add_column :publication_translations, :slug, :string
    add_index :publication_translations, :slug

    add_column :issues, :slug, :string
    add_index :issues, :slug, :unique => true

    add_column :illustrations, :slug, :string
    add_index :illustrations, :slug, :unique => true
    add_column :illustration_translations, :slug, :string
    add_index :illustration_translations, :slug

    add_column :illustrators, :slug, :string
    add_index :illustrators, :slug, :unique => true
    add_column :illustrator_translations, :slug, :string
    add_index :illustrator_translations, :slug

    add_column :news, :slug, :string
    add_index :news, :slug, :unique => true
    add_column :news_translations, :slug, :string
    add_index :news_translations, :slug

    add_column :researches, :slug, :string
    add_index :researches, :slug, :unique => true
    add_column :research_translations, :slug, :string
    add_index :research_translations, :slug

  end
end
