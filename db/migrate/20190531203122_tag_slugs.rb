class TagSlugs < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :slug, :string
    add_index :tags, :slug, :unique => true
    add_column :tag_translations, :slug, :string
    add_index :tag_translations, :slug

    # populate data
    puts "- creating slugs"
    reversible do |dir|
      dir.up do
        Tag.find_each(&:save)
      end

      dir.down do
        # do nothing
      end
    end
  end
end
