class Illustration < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  has_one_attached :image
  # have to add method to delete attached file
  attr_accessor :remove_image
  after_save { asset.purge if remove_image == '1' }

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustrator
  has_many :illustration_tags, dependent: :destroy
  has_many :tags, through: :illustration_tags
  has_many :illustration_publications, dependent: :destroy
  has_many :publications, through: :illustration_publications
  # has_many :publications, through: :illustration_publications, -> { not_journals }, inverse_of: :illustrations

  has_many :illustration_issues, dependent: :destroy
  has_many :issues, through: :illustration_issues

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
  ## METHODS ##
  #################
  def publications_count
    self.illustration_publications.count
  end

  def issues_count
    self.illustration_issues.count
  end

  def combined_publications_count
    publications_count + issues_count
  end

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
    # publication list should not show journals
    configure :publications do
      #TODO
    end
    configure :context do
      pretty_value do
        value.html_safe
      end
    end

    # list page
    list do
      field :image
      field :title
      field :illustrator
      field :combined_publications_count do
        label "Publication Illustrations"
      end
      field :is_public
      field :date_publish
    end

    # show page
    show do
      field :image
      field :title
      field :context
      field :illustrator
      field :combined_publications_count do
        label "Publication Illustrations"
      end
      field :tags
      field :is_public
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :image
      field :illustrator
      field :translations do
        label "Translations"
      end
      field :publications
      field :issues
      field :tags
      field :is_public
      field :date_publish
    end
  end

end
