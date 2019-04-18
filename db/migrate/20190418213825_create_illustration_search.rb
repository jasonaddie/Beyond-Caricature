class CreateIllustrationSearch < ActiveRecord::Migration[5.2]
  def change
    add_index :illustration_translations, "to_tsvector('simple', title || ' ' || context )", using: :gin, name: 'idx_illustration_search'
    add_index :tag_translations, "to_tsvector('simple', name )", using: :gin, name: 'idx_tag_search'
  end
end
