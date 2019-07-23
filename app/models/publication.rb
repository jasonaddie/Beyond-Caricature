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
#  crop_alignment          :string           default("center")
#

class Publication < ApplicationRecord
  include FullTextSearch
  include CropAlignment
  include RejectNestedObject

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
  belongs_to :publication_language, -> { published }
  has_many :issues, dependent: :nullify
  has_many :illustration_publications, dependent: :destroy
  has_many :illustrations, through: :illustration_publications
  has_many :publication_editors, dependent: :destroy
  has_many :related_items, dependent: :nullify
  accepts_nested_attributes_for :publication_editors, allow_destroy: true,
    reject_if: ->(editor){ reject_nested_object?(editor, ['year_start', 'year_end',
                                                    {'person_roles_attributes': ['role_id', 'person_id']}])}

  has_many :person_roles, as: :person_roleable, dependent: :destroy
  accepts_nested_attributes_for :person_roles, allow_destroy: true,
    reject_if: ->(role){ reject_nested_object?(role, %w(role_id person_id))}


  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :about, :is_public, :published_at, :slug, :versioning => :paper_trail
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
      [:title, :year],
      [:title, :year, :publication_type]
    ]
  end

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
  validates_size_of :scanned_file, maximum: 30.megabytes
  validates_property :ext, of: :cover_image, in: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']
  validates_property :ext, of: :scanned_file, as: 'pdf'

  #################
  ## CALLBACKS ##
  #################
  before_save :set_translation_published_at
  validate :check_self_public_required_fields

  #################
  ## SCOPES ##
  #################
  scope :journals, -> { where(publication_type: :journal) }
  scope :not_journals, -> { where.not(publication_type: :journal) }
  scope :published, -> { with_translations(I18n.locale).where('publication_translations.is_public': true) }
  scope :sort_published_desc, -> { order(published_at: :desc) }
  scope :sort_name_asc, -> { select('publications.*, publication_translations.title, publication_translations.published_at').with_translations(I18n.locale).order('publication_translations.title asc, publication_translations.published_at asc') }

  # search query for the list admin page
  # - title
  # - language
  # - source type
  def self.admin_search(q)
    ids = []

    # publication title
    publications = self.with_translations(I18n.locale)
          .where(build_full_text_search_sql(%w(publication_translations.title)),
            q
          ).pluck(:id)

    if publications.present?
      ids << publications
    end

    # publication language
    # - search languages and then get the publications that has those languages
    languages = PublicationLanguage.with_translations(I18n.locale)
          .where(build_full_text_search_sql(%w(publication_language_translations.language)),
            q
          ).pluck(:id)

    if languages.present?
      publication_languages = self.where(publication_language_id: languages)
      if publication_languages.present?
        ids << publication_languages
      end
    end

    # source type
    # - have to search through locale values and if match, get key
    #   and then find matches
    locale_text = I18n.t('activerecord.attributes.publication.publication_types')
    matches = []
    locale_text.each do |key, text|
      if text.downcase.starts_with?(q.downcase)
        matches << key
      end
    end

    if matches.present?
      source_types = self.where(publication_type: matches).pluck(:id)
      if source_types.present?
        ids << source_types
      end
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
    pub_years = self.published.pluck(:year).uniq.reject(&:blank?)
    issue_dates = Issue.published.pluck(:date_publication).uniq.reject(&:blank?)
    if issue_dates.present?
      pub_years << issue_dates.map{|x| x.year}
    end
    if pub_years.present?
      pub_years.flatten!
      pub_years.uniq!
      pub_years.sort!
      range = {min: pub_years.first, max: pub_years.last}
    end

    return range
  end

  # filter people by the following:
  # - publication type - publication_type enum
  # - publication language - language id
  # - person - slug of person that is assigned to this publication
  # - role - slug of role
  # - date_start - publication start date
  # - date_end - publication end date
  # - search - string
  def self.filter(options={})
    x = self
    if options[:type].present?
      x = x.where(publication_type: options[:type])
    end

    if options[:language].present?
      x = x.where(publication_language_id: PublicationLanguage.published.where(slug: options[:language]).pluck(:id))
    end

    if options[:person].present?
      # see if person exists
      # if so, get all publications or publication editors this person is assigned to
      p = Person.published.select('id').where(slug: options[:person]).first
      if p.present?
        pub_ids = PersonRole.where(person_id: p.id, person_roleable_type: 'Publication').pluck(:person_roleable_id)
        pub_editor_ids = PersonRole.where(person_id: p.id, person_roleable_type: 'PublicationEditor').pluck(:person_roleable_id)
        if pub_editor_ids.present?
          pub_ids << PublicationEditor.where(id: pub_editor_ids).pluck(:publication_id)
          pub_ids.flatten!
          pub_ids.uniq!
        end
        x = x.where(id: pub_ids)
      else
        x = x.none
      end
    end

    if options[:role].present?
      role_id = Role.where(slug: options[:role]).pluck(:id).first
      if role_id.present?
        pub_ids = PersonRole.where(role_id: role_id, person_roleable_type: 'Publication').pluck(:person_roleable_id)
        pub_editor_ids = PersonRole.where(role_id: role_id, person_roleable_type: 'PublicationEditor').pluck(:person_roleable_id)
        if pub_editor_ids.present?
          pub_ids << PublicationEditor.where(id: pub_editor_ids).pluck(:publication_id)
          pub_ids.flatten!
          pub_ids.uniq!
        end
        x = x.where(id: pub_ids)
      else
        x = x.none
      end
    end

    if options[:date_start].present? && options[:date_end].present?
      # get dates from publication and issue records
      from_issues = Issue.published.where(['date_publication between ? and ?', options[:date_start], options[:date_end]]).pluck(:publication_id)
      pub_ids = Publication.where(['year between ? and ?', options[:date_start].year, options[:date_end].year]).pluck(:id)
      if from_issues.present?
        pub_ids << from_issues
        pub_ids.flatten!
        pub_ids.uniq!
      end
      x = x.where(id: pub_ids)

    elsif options[:date_start].present?
      # get dates from publication and issue records
      from_issues = Issue.published.where('date_publication >= ?', options[:date_start]).pluck(:publication_id)
      pub_ids = Publication.where('year >= ?', options[:date_start].year).pluck(:id)
      if from_issues.present?
        pub_ids << from_issues
        pub_ids.flatten!
        pub_ids.uniq!
      end
      x = x.where(id: pub_ids)

    elsif options[:date_end].present?
      # get dates from publication and issue records
      from_issues = Issue.published.where('date_publication <= ?', options[:date_end]).pluck(:publication_id)
      pub_ids = Publication.where('year >= ?', options[:date_end].year).pluck(:id)
      if from_issues.present?
        pub_ids << from_issues
        pub_ids.flatten!
        pub_ids.uniq!
      end
      x = x.where(id: pub_ids)
    end

    if options[:search].present?
      x = x.with_translations(I18n.locale)
            .where(build_full_text_search_sql(%w(publication_translations.title publication_translations.about)),
              options[:search]
            )
    end

    return x.distinct
  end

  def self.publication_types_for_select
    options = {}
    publication_types.each do |key, value|
      options[I18n.t("activerecord.attributes.#{model_name.i18n_key}.publication_types.#{key}")] = value
    end
    return options
  end

  def self.publication_types_for_select2
    options = {}
    publication_types.each do |key, value|
      options[I18n.t("activerecord.attributes.#{model_name.i18n_key}.publication_types.#{key}")] = key
    end
    return options
  end

  #################
  ## METHODS ##
  #################
  def issue_count
    self.issues.published.count if self.journal?
  end

  def illustration_count
    if self.journal?
      self.issues.published.map{|x| x.illustrations.published.count}.inject(0, :+)
    else
      self.illustrations.published.count
    end
  end

  def has_public_translation?
    !self.is_public_translations.values.index(true).nil?
  end

  # show the translated name of the enum value
  def publication_type_formatted
    self.publication_type? ? I18n.t("activerecord.attributes.#{model_name.i18n_key}.publication_types.#{publication_type}") : nil
  end

  def language
    self.publication_language.present? ? self.publication_language.language : nil
  end

  # get the date of the record
  # - for journals, this is based on the issue dates
  # - for book and originals, this is the year
  def date
    if self.journal?
      self.issues.start_end_dates
    else
      self.year.to_s
    end
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
    configure :crop_alignment do
      pretty_value do
        bindings[:view].content_tag(:div, bindings[:object].crop_alignment_formatted) +
        if bindings[:object].cover_image.present?
          bindings[:view].tag(:br) +
          bindings[:view].image_tag(bindings[:object].cover_image.thumb(bindings[:object].generate_image_size_syntax(:wide_small)).url, class: 'img-thumbnail')
        end
      end
    end
    # create link to file
    configure :scanned_file do
      html_attributes required: required? && !value.present?, accept: '.pdf'
      image false
      pretty_value do
        if bindings[:object].scanned_file.present?
          bindings[:view].content_tag(:a,
            I18n.t('labels.view_file_with_size',
                    size: ActionController::Base.helpers.number_to_human_size(bindings[:object].scanned_file_size),
                    name: bindings[:object].publication_type_formatted),
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

    configure :publication_editors do
      # build a table listing the editors
      pretty_value do
        bindings[:view].content_tag(:table, class: 'table table-striped publication-editors') do
          bindings[:view].content_tag(:thead) do
            bindings[:view].content_tag(:tr) do
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:year_start)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:year_end)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:person_role))
            end
          end +
          bindings[:view].content_tag(:tbody) do
            bindings[:object].publication_editors.collect do |publication_editor|
              bindings[:view].content_tag(:tr) do
                bindings[:view].content_tag(:td, publication_editor.year_start) +
                bindings[:view].content_tag(:td, publication_editor.year_end) +
                bindings[:view].content_tag(:td) do
                  bindings[:view].content_tag(:ul) do
                    publication_editor.person_roles.group_person_records_by_role.collect do |role, people|
                      bindings[:view].content_tag(:li) do
                        bindings[:view].content_tag(:span, role) +
                        bindings[:view].content_tag(:ul) do
                          people.collect do |person|
                            bindings[:view].content_tag(:li) do
                              bindings[:view].link_to(person.name, bindings[:view].url_for(action: 'show', model_name: 'Person', id: person.person_id), class: 'pjax')
                            end
                          end.join.html_safe
                        end
                      end
                    end.join.html_safe
                  end
                end
              end
            end.join.html_safe
          end
        end
      end
    end

    configure :person_roles do
      # build simple list of name and role
      pretty_value do
        bindings[:view].content_tag(:ul, class: 'has-no-bullets') do
          bindings[:object].person_roles.group_people_by_role.collect do |role, people|
            bindings[:view].content_tag(:li) do
              bindings[:view].content_tag(:span, role) +
              bindings[:view].content_tag(:ul) do
                people.collect do |person|
                  bindings[:view].content_tag(:li) do
                    bindings[:view].link_to(person.name, bindings[:view].url_for(action: 'show', model_name: 'Person', id: person.person_id), class: 'pjax')
                  end
                end.join.html_safe
              end
            end
          end.join.html_safe
        end
      end
    end

    configure :published_at do
      # remove the time zone
      pretty_value do
        value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
      end
    end

    configure :updated_at do
      # remove the time zone
      pretty_value do
        value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
      end
    end

    # list page
    list do
      search_by :admin_search

      field :is_public
      field :cover_image
      field :publication_type
      field :publication_language
      field :title
      field :year
      field :published_at
      field :updated_at
    end

    # show page
    show do
      field :is_public
      field :cover_image do
        thumb_method '150x'
      end
      field :crop_alignment
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
      field :person_roles
      field :year do
        visible do
          bindings[:object].book? || bindings[:object].original?
        end
      end
      field :published_at
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
        help "#{I18n.t('admin.help.image_size.publication')} #{I18n.t('admin.help.image')}"
      end
      field :crop_alignment do
        help I18n.t('admin.help.crop_alignment')
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
      field :person_roles do
        css_class 'publication-person-roles'
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
