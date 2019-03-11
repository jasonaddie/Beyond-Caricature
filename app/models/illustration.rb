# == Schema Information
#
# Table name: illustrations
#
#  id             :bigint(8)        not null, primary key
#  illustrator_id :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  image_uid      :string
#

class Illustration < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  dragonfly_accessor :image

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustrator, -> { published }
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
  ## VALIDATION ##
  #################
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
    # publication list should not show journals
    configure :publications do
      #TODO
    end
    configure :context do
      pretty_value do
        value.nil? ? nil : value.html_safe
      end
    end
    configure :image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end
    configure :illustrator do
      # limit to only published issues
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:illustrator).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
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
      field :illustrator
      field :combined_publications_count do
        label I18n.t('labels.combined_publications_count')
      end
      field :date_publish
    end

    # show page
    show do
      field :is_public
      field :image
      field :title
      field :context
      field :illustrator
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
        help I18n.t('admin.help.image')
      end
      field :illustrator
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
