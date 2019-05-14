# == Schema Information
#
# Table name: illustrations
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image_uid  :string
#  person_id  :bigint(8)
#

class Illustration < ApplicationRecord
  include FullTextSearch
  include CropAlignment

  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  dragonfly_accessor :image do
    default Rails.root.join('public','images','default-square.png')
  end

  #################
  ## ASSOCIATIONS ##
  #################
  has_one :person_role, as: :person_roleable, dependent: :destroy
  accepts_nested_attributes_for :person_role, allow_destroy: true,
    reject_if: ->(role){ reject_person_role?(role)}

  has_many :illustration_tags, dependent: :destroy
  has_many :tags, through: :illustration_tags
  has_many :illustration_publications, dependent: :destroy
  has_many :publications, through: :illustration_publications
  # has_many :publications, through: :illustration_publications, -> { not_journals }, inverse_of: :illustrations
  has_many :illustration_annotations, dependent: :destroy
  accepts_nested_attributes_for :illustration_annotations, allow_destroy: true,
    reject_if: ->(annotation){ reject_annotation?(annotation)}

  has_many :illustration_issues, dependent: :destroy
  has_many :issues, through: :illustration_issues
  has_many :related_items, dependent: :nullify

  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :context, :is_public, :date_publish, :slug, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## SLUG
  #################
  extend FriendlyId
  include GlobalizeFriendlyId # overriden and extra methods for friendly id located in concern folder
  friendly_id :slug_candidates, use: [:globalize, :history, :slugged]

  # give options of what to use when the slug is already in use by another record
  def slug_candidates
    [
      :title,
      [:title, :date_publish]
    ]
  end

  #################
  ## VALIDATION ##
  #################
  validates :person_role, presence: true
  validates_size_of :image, maximum: 5.megabytes
  validates_property :ext, of: :image, in: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']

  #################
  ## CALLBACKS ##
  #################
  before_save :set_translation_publish_dates
  validate :check_self_public_required_fields

  #################
  ## SCOPES ##
  #################
  scope :published, -> { with_translations(I18n.locale).where('illustration_translations.is_public': true) }
  scope :sort_published_desc, -> { order(date_publish: :desc) }

  # filter illustrations by the following:
  # - publication type - publication type key from publication table
  # - illustrator name - name of person with illustrator role
  # - date_start - publication start date
  # - date_end - publication end date
  # - search - string (title, context, tags, source name?, illustrator name?)
  def self.filter(options={})
    x = self
    if options[:type].present?
      if options[:type].downcase == 'journal'
        x = x.joins(:issues)
      else
        x = x.joins(:publications).where(publications: {publication_type: options[:type]})
      end
    end

    if options[:illustrator].present?
      x = x.joins(:person_role).where(person_roles: {person_id: Person.published.where(slug: options[:illustrator])})
    end

    if options[:date_start].present?
      x = x.joins(:publications).where('publications.year >= ?', options[:date_start].year)
    end

    if options[:date_end].present?
      x = x.joins(:publications).where('publications.year <= ?', options[:date_end].year)
    end

    if options[:search].present?
      x = x.with_translations(I18n.locale)
            .joins(tags: :translations)
            .where(build_full_text_search_sql(%w(illustration_translations.title illustration_translations.context tag_translations.name)),
              options[:search]
            )
    end

    return x.distinct
  end



  # if there are no values in all translations, then reject
  def self.reject_annotation?(annotation)
    translation_fields = %w(annotation)
    nontranslation_fields = %w(sort x y)
    found_value = false

    # check nontranslation fields first
    nontranslation_fields.each do |field|
      if !annotation[field].blank?
        found_value = true
        break
      end
    end

    if !found_value
      # no nontranslation, value so now check translation value
      # format is {"translations_attributes"=>{"0"=>{"locale"=>"", "annotation"=>""}, "1"=>{"locale"=>"", "annotation"=>""}, ... }
      # so get values of translations_attributes hash and then check the field values
      annotation["translations_attributes"].values.each do |trans_values|
        translation_fields.each do |field|
          if !trans_values[field].blank?
            found_value = true
            break
          end
        end
        break if found_value
      end
    end

    return !found_value
  end

  # if there are no values, then reject
  def self.reject_person_role?(person)
    nontranslation_fields = %w(role_id person)
    found_value = false

    # check nontranslation fields first
    nontranslation_fields.each do |field|
      if !person[field].blank?
        found_value = true
        break
      end
    end
    return !found_value
  end



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
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.primary')

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 10

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
    configure :publications do
      # limit to only published items that are not journals
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.not_journals
        }
      end
    end
    configure :issues do
      # limit to only published issues
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published
        }
      end
    end
    configure :context do
      pretty_value do
        value.nil? ? nil : value.html_safe
      end
    end
    configure :image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end
    configure :crop_alignment do
      pretty_value do
        bindings[:object].crop_alignment_formatted
      end
    end
    configure :person_role do
      # build simple list of name and role
      pretty_value do
        value.nil? ? nil : bindings[:view].link_to(value.name, bindings[:view].url_for(action: 'show', model_name: 'Person', id: value.person_id), class: 'pjax')
      end
    end
    configure :illustration_annotations do
      # determine if the has many block should be open when page loads
      active do
        bindings[:object].illustration_annotations.present?
      end

      # show list of annotations
      pretty_value do
        bindings[:view].content_tag(:ol) do
          bindings[:object].illustration_annotations.sorted.collect do |annotation|
            bindings[:view].content_tag(:li, annotation.annotation)
          end.join.html_safe
        end
      end
    end

    # list page
    list do
      field :is_public
      field :image
      field :title
      field :person_role
      field :combined_publications_count do
        label I18n.t('labels.combined_publications_count')
      end
      field :date_publish
    end

    # show page
    show do
      field :is_public
      field :image
      field :crop_alignment
      field :title
      field :context
      field :person_role
      field :illustration_annotations
      field :combined_publications_count do
        label I18n.t('labels.combined_publications_count')
      end
      field :tags
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :image do
        help "#{I18n.t('admin.help.image_size.illustration')} #{I18n.t('admin.help.image')}"
      end
      field :crop_alignment do
        help I18n.t('admin.help.crop_alignment')
      end
      field :person_role do
        help I18n.t('admin.help.person')
      end
      field :translations do
        label I18n.t('labels.translations')
      end
      field :illustration_annotations do
        partial "form_nested_many_annotations_sorting"
      end
      field :publications
      field :issues
      field :tags
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
