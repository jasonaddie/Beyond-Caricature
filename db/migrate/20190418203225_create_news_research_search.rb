class CreateNewsResearchSearch < ActiveRecord::Migration[5.2]
  def change
    add_index :news_translations, "to_tsvector('simple', title || ' ' || summary || ' ' || text )", using: :gin, name: 'idx_news_search'
    add_index :research_translations, "to_tsvector('simple', title || ' ' || summary || ' ' || text )", using: :gin, name: 'idx_research_search'
  end
end
