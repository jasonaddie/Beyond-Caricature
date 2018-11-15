class Research < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :summary, :text
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :title, presence: true
  # translation_class.validates :text, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 300

    # configuration
    configure :date_publish do
      date_format :default
      datepicker_options showTodayButton: true, format: 'YYYY-MM-DD'
    end

    # list page
    list do
      field :title
      field :summmary
      field :is_public
      field :date_publish
    end

    # show page
    show do
      field :title
      field :summary
      field :text
      field :is_public
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label "Translations"
      end
      field :is_public
      field :date_publish
    end
  end
end
