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


  # build the hash syntax for the og and twitter image
  # that has both the passed in image and the default share image
  def generate_share_image_syntax(model, img_obj)
    if model.send("#{img_obj}_stored?")
      image_url = model.send(img_obj).thumb(model.generate_image_size_syntax(:share)).url
      return {
        og:{
          image: [
            {_: request.protocol + request.host_with_port + image_url},
            {_: asset_url('share.png')}
          ]
        },
        twitter:{
          image: [
            {_: request.protocol + request.host_with_port + image_url},
            {_: asset_url('share.png')}
          ]
        }
      }
    else
      return {}
    end
  end

  # build the hash syntax for the og and twitter image
  # that has both the passed in image and the default share image
  def generate_share_image_syntax_old(image_url)
    if image_url.present?
      return {
        og:{
          image: [
            {_: request.protocol + request.host_with_port + image_url},
            {_: asset_url('share.png')}
          ]
        },
        twitter:{
          image: [
            {_: request.protocol + request.host_with_port + image_url},
            {_: asset_url('share.png')}
          ]
        }
      }
    else
      return {}
    end
  end


  # if the publication is a journal, there may be publication roles
  # and if there are, these roles have years assigned to them,
  # so we then have to see if the role also exists in publication roles
  # and if so, they need to be merged
  # return format: { Role: { Unknown: [person, person, person], 1920: [person] } }
  def merge_publication_roles(publication, publication_editors)
    roles = {}

    if publication.present?
      publication_roles = publication.person_roles.group_people_by_role

      # add publication roles
      if publication_roles.present?
        unknown_key = I18n.t('labels.unknown')
        publication_roles.each do |role, people|
          roles[role] = {}
          roles[role][unknown_key] = []
          people.each do |person|
            roles[role][unknown_key] << person
          end
        end
      end

      # add publication editor roles
      if publication_editors.present?
        publication_editors.each do |publication_editor|
          pe_roles = publication_editor.person_roles.group_people_by_role
          # create the hash key to put the role data into
          # if the pub editor record has no dates, use the unknown key
          # else use the start and end date to create the hash key
          date_key = if publication_editor.year_start.present? || publication_editor.year_end.present?
            (publication_editor.year_start ? publication_editor.year_start.to_s : '?') +
            ' - ' +
            (publication_editor.year_end ? publication_editor.year_end.to_s : '?')
          else
            unknown_key
          end

          if pe_roles.present?
            pe_roles.each do |pe_role, people|
              if !roles[pe_role].present?
                roles[pe_role] = {}
              end
              if !roles[pe_role][date_key].present?
                roles[pe_role][date_key] = []
              end

              people.each do |person|
                roles[pe_role][date_key] << person
              end
            end
          end
        end
      end
    end

    return roles
  end
end
