# == Schema Information
#
# Table name: page_contents
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PageContent < ApplicationRecord
  include FullTextSearch

  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## TRANSLATIONS ##
  #################
  translates :content, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  validates :name, :content, presence: true

  #################
  ## SCOPES ##
  #################
  # search query for the list admin page
  # - name
  # - content
  def self.admin_search(q)
    ids = []

    names = self.where(build_full_text_search_sql(%w(name)),
            q
          ).pluck(:id)

    if names.present?
      ids << names
    end

    contents = self.with_translations(I18n.locale)
          .where(build_full_text_search_sql(%w(page_content_translations.content)),
            q
          ).pluck(:id)

    if contents.present?
      ids << contents
    end

    ids = ids.flatten.uniq

    if ids.present?
      self.where(id: ids).distinct
    else
      self.none
    end
  end


  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.admin')

    configure :translations, :globalize_tabs

    # control the order in the admin nav menu
    weight 450

    # configuration
    configure :content do
      pretty_value do
        value.nil? ? nil : value.html_safe
      end
    end

    configure :updated_at do
      # remove the time zone
      pretty_value do
        value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
      end
    end

    # list page
    list do
      search_by :admin_search

      field :name
      field :content
      field :updated_at
    end

    # show page
    show do
      field :name
      field :content
    end

    # form
    edit do
      field :name do
        help I18n.t('admin.help.page_content_name')
        read_only do
          !bindings[:view]._current_user.superadmin?
        end
      end
      field :translations do
        label I18n.t('labels.translations')
      end
    end
  end

end
