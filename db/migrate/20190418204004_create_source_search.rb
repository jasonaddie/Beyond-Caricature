class CreateSourceSearch < ActiveRecord::Migration[5.2]
  def change
    add_index :publication_translations, "to_tsvector('simple', title || ' ' || about )", using: :gin, name: 'idx_publication_search'
  end
end
