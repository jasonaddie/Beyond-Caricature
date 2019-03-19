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
#  scanned_file_size       :integer
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
  dragonfly_accessor :cover_image do
    default Rails.root.join('public','images','default-wide.png')
  end

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :publication_language, -> { active }
  has_many :issues, dependent: :nullify
  has_many :illustration_publications, dependent: :destroy
  has_many :illustrations, through: :illustration_publications
  has_many :publication_editors, dependent: :destroy
  has_many :related_items, dependent: :nullify
  accepts_nested_attributes_for :publication_editors, allow_destroy: true,
    reject_if: ->(editor){ reject_publication_editors?(editor)}

  has_many :editor_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :editors, -> { published.with_roles('editor') }, through: :editor_people, source: :person
  has_many :publisher_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :publishers, -> { published.with_roles('publisher') }, through: :publisher_people, source: :person
  has_many :writer_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :writers, -> { published.with_roles('writer') }, through: :writer_people, source: :person
  has_many :printer_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :printers, -> { published.with_roles('printer') }, through: :printer_people, source: :person
  has_many :financier_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :financiers, -> { published.with_roles('financier') }, through: :financier_people, source: :person
  has_many :official_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :officials, -> { published.with_roles('official') }, through: :official_people, source: :person
  has_many :subject_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :subjects, -> { published.with_roles('subject') }, through: :subject_people, source: :person


  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :about, :is_public, :date_publish, :slug, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## SLUG
  #################
  extend FriendlyId
  friendly_id :title, use: [:globalize, :history, :slugged]

  # override to use all locales and not the locales that exist in the
  # translation record
  # from: https://github.com/norman/friendly_id-globalize/blob/master/lib/friendly_id/globalize.rb
  def set_slug(normalized_slug = nil)
    (I18n.available_locales.presence || [::Globalize.locale]).each do |locale|
      ::Globalize.with_locale(locale) { super_set_slug(normalized_slug) }
    end
  end

  # override to test if the base value (i.e., title) is present and if so, generate slug
  # from: https://github.com/norman/friendly_id-globalize/blob/master/lib/friendly_id/globalize.rb
  def should_generate_new_friendly_id?
    send("#{friendly_id_config.base}_translations")[::Globalize.locale.to_s].present? && translation_for(::Globalize.locale).send(friendly_id_config.slug_column).nil?
  end

  # for locale sensitive transliteration with friendly_id
  def normalize_friendly_id(input)
    input.to_s.to_url
  end

  #################
  ## ENUMS ##
  #################
  enum publication_type: [:journal, :book, :original]

  #################
  ## SCOPES ##
  #################
  scope :published, -> { with_translations(I18n.locale).where('publication_translations.is_public': true) }
  scope :sort_published_desc, -> { order(date_publish: :desc) }

  def self.publication_types_for_select
    options = {}
    publication_types.each do |key, value|
      options[I18n.t("activerecord.attributes.#{model_name.i18n_key}.publication_types.#{key}")] = value
    end
    return options
  end

  # if there are no values in all publication editor translations and years, then reject
  def self.reject_publication_editors?(editor)
    nontranslation_fields = %w(editors publishers year_start year_end)
    found_value = false

    # check nontranslation fields first
    nontranslation_fields.each do |field|
      if !editor[field].blank?
        found_value = true
        break
      end
    end

    # if !found_value
    #   # no nontranslation, value so now check translation value
    #   # format is {"translations_attributes"=>{"0"=>{"locale"=>"", "editor"=>"", "publisher"=>""}, "1"=>{"locale"=>"", "editor"=>"", "publisher"=>""}, ... }
    #   # so get values of translations_attributes hash and then check the field values
    #   editor["translations_attributes"].values.each do |trans_values|
    #     translation_fields.each do |field|
    #       if !trans_values[field].blank?
    #         found_value = true
    #         break
    #       end
    #     end
    #     break if found_value
    #   end
    # end

    return !found_value
  end


  #################
  ## VALIDATION ##
  #################
  validates :publication_type, presence: true
  validates :publication_language, presence: true
  validates :year, numericality: { greater_than: 1800, less_than_or_equal_to: Time.now.year }, unless: Proc.new { |x| x.year.blank? }
  validates :publication_editors, presence: true, if: Proc.new{ |x| x.journal? && x.has_public_translation?}
  validates_size_of :cover_image, maximum: 5.megabytes
  validates_property :ext, of: :cover_image, in: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']
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

  # show the translated name of the enum value
  def publication_type_formatted
    self.publication_type? ? I18n.t("activerecord.attributes.#{model_name.i18n_key}.publication_types.#{publication_type}") : nil
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
    configure :publication_type do
      # enum Publication.publication_types_for_select
      pretty_value do
        bindings[:object].publication_type_formatted
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
            I18n.t('labels.view_file_with_size', size: ActionController::Base.helpers.number_to_human_size(bindings[:object].scanned_file_size)),
            href: bindings[:object].scanned_file.url,
            target: '_blank',
            class: 'btn btn-info btn-sm'
          )
        end
      end
    end
    configure :publication_language do
      # limit to only published issues
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:publication_language).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
      end
    end
    configure :about do
      pretty_value do
        value.nil? ? nil : value.html_safe
      end
    end
    configure :editors do
      # limit to only published editors
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('editor').sort_name
        }
      end
    end
    configure :publishers do
      # limit to only published publishers
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('publisher').sort_name
        }
      end
    end
    configure :writers do
      # limit to only published writers
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('writer').sort_name
        }
      end
    end
    configure :printers do
      # limit to only published printers
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('printer').sort_name
        }
      end
    end
    configure :financiers do
      # limit to only published financiers
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('financier').sort_name
        }
      end
    end
    configure :officials do
      # limit to only published officials
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('official').sort_name
        }
      end
    end
    configure :subjects do
      # limit to only published subjects
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('subject').sort_name
        }
      end
    end

    configure :publication_editors do
      # build a table listing the editors
      pretty_value do
        bindings[:view].content_tag(:table, class: 'table table-striped publication-editors') do
          bindings[:view].content_tag(:thead) do
            bindings[:view].content_tag(:tr) do
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:editors)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:publishers)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:year_start)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:year_end))
            end
          end +
          bindings[:view].content_tag(:tbody) do
            bindings[:object].publication_editors.collect do |publication_editor|
              bindings[:view].content_tag(:tr) do
                bindings[:view].content_tag(:td, publication_editor.editors) +
                bindings[:view].content_tag(:td, publication_editor.publishers) +
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
        label I18n.t('labels.issue_count')
      end
      field :illustration_count do
        label I18n.t('labels.illustration_count')
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
        visible do
          bindings[:object].journal?
        end
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
      field :editors do
        visible do
          bindings[:object].book?
        end
      end
      field :publishers do
        visible do
          bindings[:object].book?
        end
      end
      field :writers do
        visible do
          bindings[:object].book?
        end
      end
      field :printers
      field :financiers
      field :officials
      field :subjects
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
      field :publication_language do
        help I18n.t('admin.help.only_active_languages')
      end
      field :cover_image do
        help I18n.t('admin.help.image')
      end
      field :scanned_file do
        css_class 'publication-file'
        help I18n.t('admin.help.file')
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
      field :editors do
        css_class 'publication-editors'
        help I18n.t('admin.help.person.editor')
      end
      field :publishers do
        css_class 'publication-publishers'
        help I18n.t('admin.help.person.publisher')
      end
      field :writers do
        css_class 'publication-writers'
        help I18n.t('admin.help.person.writer')
      end
      field :printers do
        help I18n.t('admin.help.person.printer')
      end
      field :financiers do
        help I18n.t('admin.help.person.financier')
      end
      field :officials do
        help I18n.t('admin.help.person.official')
      end
      field :subjects do
        help I18n.t('admin.help.person.subject')
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
