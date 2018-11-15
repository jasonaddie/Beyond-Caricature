class Publication < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :publication_language
  has_many :issues, dependent: :nullify
  has_many :illustration_publications, dependent: :destroy
  has_many :illustrations, through: :illustration_publications

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
  ## SCOPES ##
  #################
  scope :journals, -> { where(publication_type: :journal) }
  scope :not_journals, -> { where.not(publication_type: :journal) }

  #################
  ## METHODS ##
  #################
  def issue_count
    self.issues.count if self.journal?
  end

  def illustration_count
    if self.journal?
      IllustrationIssue.where(issue_id: self.issue_ids).count
    else
      self.illustration_publications.count
    end
  end


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
      field :publication_type
      field :publication_language
      field :title
      field :issue_count do
        label "Issues on File"
      end
      field :illustration_count do
        label "Illustrations on File"
      end
      field :is_public
      field :date_publish
    end

    # show page
    show do
      field :publication_type
      field :publication_language
      field :title
      field :issue_count do
        label "Issues on File"
      end
      field :illustration_count do
        label "Illustrations on File"
      end
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

      field :is_public
      field :date_publish
    end
  end
end
