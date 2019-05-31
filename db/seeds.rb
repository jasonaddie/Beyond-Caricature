# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#########################
## ROLES
#########################
Role.destroy_all
%w(Illustrator Editor Publisher Writer Printer Financier Official Subject).each do |role|
  Role.create(name: role)
end

#########################
## Page Content
#########################
PageContent.destroy_all

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

pg = PageContent.new(name: 'contributors')
pg.content_translations = content
pg.save

I18n.locale = original_locale
