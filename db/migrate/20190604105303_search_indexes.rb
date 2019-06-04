class SearchIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :highlight_translations, "to_tsvector('simple', title || ' ' || summary )", using: :gin, name: 'idx_highlight_search'
    add_index :page_contents, "to_tsvector('simple', name )", using: :gin, name: 'idx_page_content_search1'
    add_index :page_content_translations, "to_tsvector('simple', content )", using: :gin, name: 'idx_page_content_search2'
    add_index :publication_language_translations, "to_tsvector('simple', language )", using: :gin, name: 'idx_publication_language_search'
    add_index :role_translations, "to_tsvector('simple', name )", using: :gin, name: 'idx_role_search'
    add_index :users, "to_tsvector('simple', name || ' ' || email )", using: :gin, name: 'idx_user_search'
    add_index :issues, "to_tsvector('simple', issue_number )", using: :gin, name: 'idx_issue_search'

  end
end
