class LanguageSlugs < ActiveRecord::Migration[5.2]
  def change
    add_column :publication_languages, :slug, :string
    add_index :publication_languages, :slug, :unique => true
    add_column :publication_language_translations, :slug, :string
    add_index :publication_language_translations, :slug

    # populate data
    puts "- creating slugs"
    reversible do |dir|
      dir.up do
        PublicationLanguage.find_each(&:save)
      end

      dir.down do
        # do nothing
      end
    end
  end
end
