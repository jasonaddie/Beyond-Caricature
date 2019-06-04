class FixPersonSearchIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :person_translations, name: 'idx_person_search'
    add_index :person_translations, "to_tsvector('simple', first_name || ' ' || last_name || ' ' || bio )", using: :gin, name: 'idx_person_search'
  end

  def down
    remove_index :person_translations, name: 'idx_person_search'
    add_index :person_translations, "to_tsvector('simple', name || ' ' || bio )", using: :gin, name: 'idx_person_search'
  end
end
