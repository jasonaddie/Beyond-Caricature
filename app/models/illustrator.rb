class Illustrator < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## TRANSLATIONS ##
  #################
  translates :name, :bio
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  translation_class.validates :name, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 100

    # configuration
    configure :date_birth do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY-MM-DD', viewMode: 'decades'
    end
    configure :date_death do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY-MM-DD', viewMode: 'decades'
    end

    # list page
    list do
      field :name
      field :bio
      field :date_birth
      field :date_death
      field :is_public
    end

    # show page
    show do
      field :name
      field :bio
      field :date_birth
      field :date_death
      field :is_public
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label "Translations"
      end
      field :date_birth
      field :date_death
      field :is_public
    end
  end
end
