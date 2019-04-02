module FullTextSearch
  extend ActiveSupport::Concern

  included do

    # built the pg full text search sql for the provided fields
    # - fields = array of field names, including the table name
    #   - ex: ['person_translations.name', 'person_translations.bio']
    # will generate a string similar to the following:
    #   "to_tsvector('simple', coalesce(person_translations.name::text, '') || ' ' || coalesce(person_translations.bio::text, '')) @@ (to_tsquery('simple', ''' ' || ? || ' ''' || ':*'))"
    # which means:
    # - search in person_translations name and/or bio fields
    # - :* - this means that the search term only needs to be at the beginning of the word, not the entire word
    # - ? - this is where the search string will be inserted
    def self.build_full_text_search_sql(fields)
      sql = ''
      if fields.present? && fields.class == Array
        sql = "to_tsvector('simple', "
        sql << fields.map{|x| "coalesce(#{x}::text, '')"}.join(" || ' ' || ")
        sql << ") @@ (to_tsquery('simple', ''' ' || ? || ' ''' || ':*'))"
      end

      return sql
    end
  end
end