class CreatePersonSearchIdx < ActiveRecord::Migration[5.2]
  def change
    add_index :person_translations, "to_tsvector('simple', name || ' ' || bio )", using: :gin, name: 'idx_person_search'
  end
end
