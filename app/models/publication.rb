class Publication < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :publication_language

  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :about, :editor, :publisher, :writer
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## ENUMS ##
  #################
  enum publication_type: [:journal, :book, :original]

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :title, presence: true
  validates :publication_type, presence: true
  validates :publication_language, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 20

    # configuration
    configure :date_publish do
      date_format :default
      datepicker_options showTodayButton: true, format: 'YYYY-MM-DD'
    end
    configure :date_publication do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY', viewMode: 'decades'
    end
    configure :year_publication_start, :date do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY', viewMode: 'decades'
    end
    configure :year_publication_end, :date do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY', viewMode: 'decades'
    end

    # list page
    list do
      field :title
      field :publication_type
      field :publication_language
      field :is_public
      field :date_publish
    end

    # show page
    show do
      field :title
      field :publication_type
      field :publication_language
      field :about
      field :editor
      field :publisher
      field :writer
      field :is_public
      field :date_publish
      field :year_publication_start
      field :year_publication_end
      field :date_publication
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :publication_type
      field :publication_language

      field :translations do
        label "Translations"
      end

      field :year_publication_start
      field :year_publication_end
      field :date_publication

      field :date_publish
      field :is_public
    end
  end
end
