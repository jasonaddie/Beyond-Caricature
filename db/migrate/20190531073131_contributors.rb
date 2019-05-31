class Contributors < ActiveRecord::Migration[5.2]
  def up
    pg = PageContent.new(name: 'contributors')

    fake_text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    content = {}
    I18n.available_locales.each {|locale| content[locale.to_s] = fake_text}

    pg.content_translations = content
    pg.save
  end

  def down
    PageContent.where(name: 'contributors').delete_all
  end
end
