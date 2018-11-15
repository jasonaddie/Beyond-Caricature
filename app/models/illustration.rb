class Illustration < ApplicationRecord

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustrator

  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :context
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :title, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 50

    # configuration
    configure :date_publish do
      date_format :default
      datepicker_options showTodayButton: true, format: 'YYYY-MM-DD'
    end

    # list page
    list do
      field :title
      field :illustrator
      field :is_public
      field :date_publish
    end

    # show page
    show do
      field :title
      field :illustrator
      field :is_public
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :illustrator
      field :translations do
        label "Translations"
      end
      field :date_publish
      field :is_public
    end
  end

end
