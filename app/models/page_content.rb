class PageContent < ApplicationRecord
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

    # list page
    list do
      field :name
      field :content
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
