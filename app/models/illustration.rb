class Illustration < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustrator
  has_many :illustration_tags, dependent: :destroy
  has_many :tags, through: :illustration_tags

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
    weight 10

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
      field :context
      field :illustrator
      field :tags
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
      field :tags
      field :is_public
      field :date_publish
    end
  end

end
