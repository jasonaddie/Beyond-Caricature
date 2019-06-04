# == Schema Information
#
# Table name: illustrations
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  image_uid      :string
#  person_id      :bigint(8)
#  crop_alignment :string           default("center")
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
  translates :title, :context, :is_public, :published_at, :slug, :versioning => :paper_trail
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
      [:title, :published_at]
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
  before_save :set_translation_published_at
  validate :check_self_public_required_fields

  #################
  ## SCOPES ##
  #################
  scope :published, -> { with_translations(I18n.locale).where('illustration_translations.is_public': true) }
  scope :sort_published_desc, -> { order(published_at: :desc) }


  # search query for the list admin page
  # - illustration title
  # - publication name
  # - person name
  # - tag name
  def self.admin_search(q)
    ids = []

    # illustration title and context
    illustrations = self.with_translations(I18n.locale)
          .where(build_full_text_search_sql(%w(illustration_translations.title illustration_translations.context)),
            q
          ).pluck(:id)

    if illustrations.present?
      ids << illustrations
    end

    # publication name
    publications = self.joins(publications: :translations)
          .where(publication_translations: {locale: I18n.locale})
          .where(build_full_text_search_sql(%w(publication_translations.title)),
            q
          ).pluck(:id)

    if publications.present?
      ids << publications
    end

    # person name
    # - first search for people that might match
    # - then if matches found, get which ones are assigned to illustrations
    people = Person.with_translations(I18n.locale)
              .where(build_full_text_search_sql(%w(person_translations.first_name person_translations.last_name)),
                q
              ).pluck(:id)

    if people.present?
      people_illustrations = self.joins(:person_role)
                            .where(person_roles: {person_id: people})
                            .pluck(:id)

      if people_illustrations.present?
        ids << people_illustrations
      end
    end

    # tag name
    tags = self.joins(tags: :translations)
          .where(tag_translations: {locale: I18n.locale})
          .where(build_full_text_search_sql(%w(tag_translations.name)),
            q
          ).pluck(:id)

    if tags.present?
      ids << tags
    end

    ids = ids.flatten.uniq

    if ids.present?
      self.where(id: ids).distinct
    else
      self.none
    end
  end

  # get the min and max date values
  def self.date_ranges
    range = nil

    # get published records
    pubs = Publication.published.pluck(:id, :year)
    issues = Issue.published.pluck(:id, :date_publication)
    illustrations = self.published.pluck(:id)

    if illustrations.present? && (pubs.present? || issues.present?)
      # get ids of pubs and issues that also have published illustrations
      illustration_pubs = IllustrationPublication.where(publication_id: pubs.map{|x| x[0]}, illustration_id: illustrations).pluck(:publication_id).uniq
      illustration_issues = IllustrationIssue.where(issue_id: issues.map{|x| x[0]}, illustration_id: illustrations).pluck(:issue_id).uniq

      years = []
      if illustration_pubs.present?
        years << pubs.select{|x| illustration_pubs.include?(x[0])}.map{|x| x[1]}
      end
      if illustration_issues.present?
        years << issues.select{|x| illustration_issues.include?(x[0])}.map{|x| x[1].year}
      end

      if years.present?
        years.flatten!
        years.uniq!
        years = years.reject(&:blank?)
        years.sort!
        range = {min: years.first, max: years.last}
      end
    end

    return range
  end

  # filter illustrations by the following:
  # - publication type - publication type key from publication table
  # - person - slug of person assigned to illustrations
  # - role - slug of role
  # - source - slug of publication assgined to illustrations
  # - journal / issue - slugs of journal and issue assigned to illustrations
  # - tag - slug of a tag assigned to illustrations
  # - date_start - publication start date
  # - date_end - publication end date
  # - search - string (title, context)
  def self.filter(options={})
    x = self
    if options[:type].present?
      if options[:type].downcase == 'journal'
        x = x.joins(:issues)
      else
        x = x.joins(:publications).where(publications: {publication_type: options[:type]})
      end
    end

    if options[:person].present?
      x = x.joins(:person_role).where(person_roles: {person_id: Person.published.where(slug: options[:person]).pluck(:id)})
    end

    if options[:role].present?
      x = x.joins(:person_role).where(person_roles: {role_id: Role.where(slug: options[:role]).pluck(:id)})
    end

    if options[:source].present?
      x = x.joins(:publications).where(publications: {id: Publication.published.where(slug: options[:source]).pluck(:id)})
    end

    if options[:journal].present? && options[:issue].present?
      x = x.joins(:issues).where(issues: {id: Issue.published.where(slug: options[:issue]).pluck(:id),
                                          publication_id: Publication.published.where(slug: options[:journal]).pluck(:id)})
    end

    if options[:tag].present?
      x = x.joins(:tags).where(tags: {id: Tag.where(slug: options[:tag]).pluck(:id)})
    end

    if options[:date_start].present? && options[:date_end].present?
      # get dates from publication and issue records
      illustration_ids = []
      issue_ids = Issue.published.where(['date_publication between ? and ?', options[:date_start], options[:date_end]]).pluck(:id)
      if issue_ids.present?
        illustration_ids << IllustrationIssue.where(issue_id: issue_ids).pluck(:illustration_id)
      end
      pub_ids = Publication.where(['year between ? and ?', options[:date_start].year, options[:date_end].year]).pluck(:id)
      if pub_ids.present?
        illustration_ids << IllustrationPublication.where(publication_id: pub_ids).pluck(:illustration_id)
      end
      if illustration_ids.present?
        illustration_ids.flatten!
        illustration_ids.uniq!
        x = x.where(id: illustration_ids)
      else
        x = x.none
      end

    elsif options[:date_start].present?
      # get dates from publication and issue records
      illustration_ids = []
      issue_ids = Issue.published.where('date_publication >= ?', options[:date_start]).pluck(:id)
      if issue_ids.present?
        illustration_ids << IllustrationIssue.where(issue_id: issue_ids).pluck(:illustration_id)
      end
      pub_ids = Publication.where('year >= ?', options[:date_start].year).pluck(:id)
      if pub_ids.present?
        illustration_ids << IllustrationPublication.where(publication_id: pub_ids).pluck(:illustration_id)
      end
      if illustration_ids.present?
        illustration_ids.flatten!
        illustration_ids.uniq!
        x = x.where(id: illustration_ids)
      else
        x = x.none
      end

    elsif options[:date_end].present?
      # get dates from publication and issue records
      illustration_ids = []
      issue_ids = Issue.published.where('date_publication <= ?', options[:date_end]).pluck(:id)
      if issue_ids.present?
        illustration_ids << IllustrationIssue.where(issue_id: issue_ids).pluck(:illustration_id)
      end
      pub_ids = Publication.where('year <= ?', options[:date_end].year).pluck(:id)
      if pub_ids.present?
        illustration_ids << IllustrationPublication.where(publication_id: pub_ids).pluck(:illustration_id)
      end
      if illustration_ids.present?
        illustration_ids.flatten!
        illustration_ids.uniq!
        x = x.where(id: illustration_ids)
      else
        x = x.none
      end

    end

    if options[:search].present?
      x = x.with_translations(I18n.locale)
            .where(build_full_text_search_sql(%w(illustration_translations.title illustration_translations.context)),
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
        bindings[:view].content_tag(:div, bindings[:object].crop_alignment_formatted) +
        if bindings[:object].image.present?
          bindings[:view].tag(:br) +
          bindings[:view].image_tag(bindings[:object].image.thumb(bindings[:object].generate_image_size_syntax(:square_small)).url, class: 'img-thumbnail')
        end
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
      search_by :admin_search

      field :is_public
      field :image
      field :title
      field :person_role
      field :combined_publications_count do
        label I18n.t('labels.combined_publications_count')
      end
      field :published_at
    end

    # show page
    show do
      field :is_public
      field :image do
        thumb_method '150x'
      end
      field :crop_alignment
      field :title
      field :context
      field :person_role
      field :illustration_annotations
      field :combined_publications_count do
        label I18n.t('labels.combined_publications_count')
      end
      field :tags
      field :published_at
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
