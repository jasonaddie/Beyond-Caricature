# == Schema Information
#
# Table name: publications
#
#  id                      :integer          not null, primary key
#  publication_type        :integer          default("journal")
#  publication_language_id :integer
#  is_public               :boolean          default(FALSE)
#  date_publish            :date
#  year_publication_start  :integer
#  year_publication_end    :integer
#  date_publication        :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Publication < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  has_one_attached :scanned_file
  # have to add method to delete attached file
  attr_accessor :remove_scanned_file
  after_save { asset.purge if remove_scanned_file == '1' }

  has_one_attached :cover_image
  # have to add method to delete attached file
  attr_accessor :remove_cover_image
  after_save { asset.purge if remove_cover_image == '1' }

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
      datepicker_options showTodayButton: false, format: 'YYYY', viewMode: 'years', minDate: '1800-01-01', maxDate: "#{Time.now.year}-12-31"
    end
    configure :year_publication_start, :date do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY', viewMode: 'years', minDate: '1800-01-01', maxDate: "#{Time.now.year}-12-31"
    end
    configure :year_publication_end, :date do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY', viewMode: 'years', minDate: '1800-01-01', maxDate: "#{Time.now.year}-12-31"
    end
    # create link to file
    configure :scanned_file do
      pretty_value do
        bindings[:view].content_tag(:a,
          'View',
          href: Rails.application.routes.url_helpers.rails_blob_path(bindings[:object].scanned_file, only_path: true),
          target: '_blank',
          class: 'btn btn-info btn-sm'
        )
      end
    end
    configure :about do
      pretty_value do
        value.html_safe
      end
    end

    # list page
    list do
      field :cover_image
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
      field :cover_image
      field :publication_type
      field :publication_language
      field :scanned_file
      field :title
      field :issue_count do
        label I18n.t('labels.issue_count')
      end
      field :illustration_count do
        label I18n.t('labels.illustration_count')
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
      field :cover_image
      field :scanned_file

      field :translations do
        label I18n.t('labels.translations')
      end

      field :year_publication_start
      field :year_publication_end
      field :date_publication

      field :is_public
      field :date_publish
    end
  end
end
