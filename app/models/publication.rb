# == Schema Information
#
# Table name: publications
#
#  id                      :bigint(8)        not null, primary key
#  publication_type        :integer          default("journal")
#  publication_language_id :bigint(8)
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
  translates :title, :about, :editor, :publisher, :writer, :is_public, :date_publish, :versioning => :paper_trail
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
  ## CALLBACKS ##
  #################
  before_save :set_translation_publish_dates
  validate :check_public_required_fields

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
    # group with illustrations in navigation
    parent Illustration

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 20

    # configuration
    configure :is_public do
      # build an inline list that shows the status of each language
      pretty_value do
        bindings[:view].content_tag(:ul, class: 'list-inline is-public-status') do
          I18n.available_locales.collect do |locale|
            bindings[:view].content_tag(
              :li,
              locale.upcase,
              class: bindings[:object].send("is_public_translations")[locale] ? 'public' : 'not-public',
              title: I18n.t("languages.#{locale}") + ' - ' + I18n.t("status.#{bindings[:object].send("is_public_translations")[locale]}")
            )
          end.join.html_safe
        end
      end
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
    configure :cover_image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end
    # create link to file
    configure :scanned_file do
      html_attributes required: required? && !value.present?, accept: '.pdf'
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
        value.nil? ? nil : value.html_safe
      end
    end

    # list page
    list do
      field :is_public
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
      field :date_publish
    end

    # show page
    show do
      field :is_public
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
      field :year_publication_start
      field :year_publication_end
      field :date_publication
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :publication_type do
        html_attributes class: 'publication-type'
      end
      field :publication_language
      field :cover_image
      field :scanned_file do
        css_class 'publication-file'
      end

      field :translations do
        label I18n.t('labels.translations')
      end

      field :year_publication_start do
        css_class 'publication-year-start'
      end
      field :year_publication_end do
        css_class 'publication-year-end'
      end
      field :date_publication do
        css_class 'publication-date'
      end
    end
  end


  #################
  ## PRIVATE METHODS ##
  #################
  private

  def check_public_required_fields
    # call the methohd in the application record base object
    super(%w(title))
  end
end
