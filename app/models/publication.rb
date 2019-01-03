# == Schema Information
#
# Table name: publications
#
#  id                      :bigint(8)        not null, primary key
#  publication_type        :integer
#  publication_language_id :bigint(8)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  year                    :integer
#  cover_image_uid         :string
#  scanned_file_uid        :string
#

class Publication < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  dragonfly_accessor :scanned_file
  dragonfly_accessor :cover_image

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :publication_language
  has_many :issues, dependent: :nullify
  has_many :illustration_publications, dependent: :destroy
  has_many :illustrations, through: :illustration_publications
  has_many :publication_editors, dependent: :destroy
  accepts_nested_attributes_for :publication_editors, allow_destroy: true,
    reject_if: ->(edior){ edior['editor'].blank? && edior['publisher'].blank? && edior['year_start'].blank? && edior['year_end'].blank?}
  has_many :related_items, dependent: :nullify

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
  validates :publication_type, presence: true
  validates :publication_language, presence: true
  validates :year, numericality: { greater_than: 1800, less_than_or_equal_to: Time.now.year }, unless: Proc.new { |x| x.year.blank? }
  validates :publication_editors, presence: true, if: Proc.new{ |x| x.journal? && x.has_public_translation?}
  validates_size_of :cover_image, maximum: 5.megabytes
  validates_property :ext, of: :cover_image, in: ['jpg', 'jpeg', 'png']
  validates_property :ext, of: :scanned_file, as: 'pdf'

  #################
  ## CALLBACKS ##
  #################
  before_save :set_translation_publish_dates
  validate :check_self_public_required_fields

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

  def has_public_translation?
    !self.is_public_translations.values.index(true).nil?
  end


  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.primary')

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
    configure :cover_image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end
    # create link to file
    configure :scanned_file do
      html_attributes required: required? && !value.present?, accept: '.pdf'
      image false
      pretty_value do
        if bindings[:object].scanned_file.present?
          bindings[:view].content_tag(:a,
            I18n.t('labels.view'),
            href: bindings[:object].scanned_file.url,
            target: '_blank',
            class: 'btn btn-info btn-sm'
          )
        end
      end
    end
    configure :about do
      pretty_value do
        value.nil? ? nil : value.html_safe
      end
    end
    configure :publication_editors do
      # build a table listing the editors
      pretty_value do
        bindings[:view].content_tag(:table, class: 'table table-striped publication-editors') do
          bindings[:view].content_tag(:thead) do
            bindings[:view].content_tag(:tr) do
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:editor)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:publisher)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:year_start)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:year_end))
            end
          end +
          bindings[:view].content_tag(:tbody) do
            bindings[:object].publication_editors.collect do |publication_editor|
              bindings[:view].content_tag(:tr) do
                bindings[:view].content_tag(:td, publication_editor.editor) +
                bindings[:view].content_tag(:td, publication_editor.publisher) +
                bindings[:view].content_tag(:td, publication_editor.year_start) +
                bindings[:view].content_tag(:td, publication_editor.year_end)
              end
            end.join.html_safe
          end
        end
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
      field :scanned_file do
        visible do
          bindings[:object].book? || bindings[:object].original?
        end
      end
      field :title
      field :issue_count do
        label I18n.t('labels.issue_count')
      end
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :about
      field :publication_editors do
        visible do
          bindings[:object].journal?
        end
      end
      field :editor do
        visible do
          bindings[:object].book?
        end
      end
      field :publisher do
        visible do
          bindings[:object].book?
        end
      end
      field :writer do
        visible do
          bindings[:object].book?
        end
      end
      field :year do
        visible do
          bindings[:object].book? || bindings[:object].original?
        end
      end
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

      field :year do
        css_class 'publication-year'
      end

      field :publication_editors do
        css_class 'publication-publication-editors'
      end
    end
  end


  #################
  ## PRIVATE METHODS ##
  #################
  private

  def check_self_public_required_fields
    # call the methohd in the application record base object
    super(%w(title))
  end
end
