module ApplicationHelper

  # update the current url by replacing the locale
  # and if this is a show page, also update the slug
  def generate_language_switcher_link(locale, record=nil, has_translations=nil, params_key=nil, use_is_public=nil, lang_switcher_fallback_url=nil)
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
          link_to(locale, lang_switcher_fallback_url.gsub("/#{I18n.locale}/", "/#{locale}/"), title: I18n.t("languages.#{locale}"))
        else
          link_to(locale, root_path(locale: locale), title: I18n.t("languages.#{locale}"))
        end
      else
        link_to(locale, request.params.merge(
                          locale: locale,
                          "#{params_key}": slug
                        ),
                title: I18n.t("languages.#{locale}")
        )
      end
    else
      link_to(locale, request.params.merge(locale: locale), title: I18n.t("languages.#{locale}"))
    end
  end

end
