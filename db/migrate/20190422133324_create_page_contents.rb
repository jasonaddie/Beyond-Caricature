class CreatePageContents < ActiveRecord::Migration[5.2]
  def change
    create_table :page_contents do |t|
      t.string :name

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        PageContent.create_translation_table! content: :text

        original_locale = I18n.locale
        fake_text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
        content = {}
        I18n.available_locales.each {|locale| content[locale.to_s] = fake_text}

        pg = PageContent.new(name: 'homepage_intro')
        pg.content_translations = content
        pg.save

        pg = PageContent.new(name: 'about')
        pg.content_translations = content
        pg.save

        I18n.locale = original_locale
      end

      dir.down do
        PageContent.drop_translation_table!
      end
    end

    add_index :page_contents, :name
  end
end
