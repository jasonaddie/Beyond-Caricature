module GlobalizeFriendlyId
  extend ActiveSupport::Concern

  included do

    # override to use all locales and not the locales that exist in the
    # translation record
    # from: https://github.com/norman/friendly_id-globalize/blob/master/lib/friendly_id/globalize.rb
    def set_slug(normalized_slug = nil)
      (I18n.available_locales.presence || [::Globalize.locale]).each do |locale|
        ::Globalize.with_locale(locale) { super_set_slug(normalized_slug) }
      end
    end

    # override to create new slug if there is text and the existing value is nil or does not match
    # from: https://github.com/norman/friendly_id-globalize/blob/master/lib/friendly_id/globalize.rb
    def should_generate_new_friendly_id?
      ((slug_candidates.first.class == Symbol && send("#{slug_candidates.first}_translations")[::Globalize.locale.to_s].present?) ||
       (slug_candidates.first.class == Array && slug_candidates.first.present? &&
          slug_candidates.first.all?{|field| send("#{field}_translations")[::Globalize.locale.to_s].present?})) && (
        translation_for(::Globalize.locale).send(friendly_id_config.slug_column).nil? ||
        !slug_candidate_values.include?(translation_for(::Globalize.locale).send(friendly_id_config.slug_column))
      )
    end

    # use the current model values to generate all possible slugs from the slug candidates
    def slug_candidate_values
      values = []

      slug_candidates.each do |candidate|
        slug = ''
        if candidate.class == Array
          candidate.each do |candidate_field|
            slug << generate_slug_candidate_value(candidate_field)
            slug << ' '
          end
        else
          slug << generate_slug_candidate_value(candidate)
        end

        values << normalize_friendly_id(slug.strip)
      end

      return values
    end

    # get the value for the candidate field
    # - try it as a translation first
    # - if that fails, then get the value without translation
    # - i.e., candidate = name -> name_translations is tried first and will work
    #         candidate = date_birth -> date_birth_translations does not exist, so then get date_birth
    def generate_slug_candidate_value(candidate)
      begin
        send("#{candidate}_translations")[::Globalize.locale.to_s].to_s
      rescue
        # this is not a translation field
        send(candidate).to_s
      end
    end

    # for locale sensitive transliteration with friendly_id
    def normalize_friendly_id(input)
      input.to_s.to_url
    end

  end
end