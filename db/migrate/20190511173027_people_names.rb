class PeopleNames < ActiveRecord::Migration[5.2]
  def change
    # create new fields
    remove_index :person_translations, :name

    add_column :person_translations, :first_name, :string
    add_column :person_translations, :last_name, :string
    add_index :person_translations, [:last_name, :first_name], name: 'idx_person_name'

    reversible do |dir|
      dir.up do
        # migrate existing names
        Person.all.each do |p|
          locales = p.name_translations.keys
          locales.each do |locale|
            I18n.locale = locale.to_sym
            if p.name_translations[locale].nil? || p.name_translations[locale].empty?
              p.first_name = ''
              p.last_name = ''
            else
              has_comma = !p.name_translations[locale].index(',').nil?
              if has_comma
                names = p.name_translations[locale].split(',')
                p.last_name = names[0].strip
                p.first_name = names[1..-1].join(', ').strip
              else
                names = p.name_translations[locale].split(' ')
                p.first_name = names[0].strip
                p.last_name = names[1..-1].join(' ').strip
                if p.last_name.empty? && p.is_public?
                  # last name is required when public, so copy first name
                  p.last_name = p.first_name
                end
              end
            end
            # vaidation of required for public fields can cause saving to fail so skip validation
            p.save(:validate => false)
          end
        end
      end
    end

  end
end
