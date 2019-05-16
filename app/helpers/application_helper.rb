module ApplicationHelper

  # update the current url by replacing the locale
  # and if this is a show page, also update the slug
  def generate_language_switcher_link(locale, record=nil, has_translations=nil, params_key=nil, use_is_public=nil, lang_switcher_fallback_url=nil)
    url = nil
    if record && params_key
      # get slug in provided locale
      # make sure the slug is also published
      slug = nil
      if has_translations
        if use_is_public
          slug = record.slug_translations[locale] if record.is_public_translations[locale]
        else
          slug = record.slug_translations[locale]
        end
      else
        slug = record.slug
      end

      if slug.nil?
        # no slug was found for the language, so go to list page
        if lang_switcher_fallback_url
          url = lang_switcher_fallback_url.gsub("/#{I18n.locale}/", "/#{locale}/")
        else
          url = root_path(locale: locale)
        end
      else
        url = request.params.merge(locale: locale, "#{params_key}": slug)
      end
    else
      url = request.params.merge(locale: locale)
    end

    if url.present?
      return link_to(locale, url, title: I18n.t("languages.#{locale}"),
                      class: "navbar-item #{I18n.locale == locale ? ' current-page' : ''}",
                      'data-turbolinks': false)
    else
      return nil
    end
  end


  def add_br_tags(text)
    text.gsub("\n", "</br>").html_safe
  end

  def generate_date_label(date_start, date_end)
    filter_date = "&nbsp;"
    if date_start.present?
      if date_end.present?
        filter_date = "#{date_start} - #{date_end}"
      else
        filter_date = " > #{date_start}"
      end
    elsif date_end.present?
      filter_date = " < #{date_end}"
    end

    return filter_date.html_safe
  end

end
