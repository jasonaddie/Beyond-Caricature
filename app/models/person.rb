# == Schema Information
#
# Table name: people
#
#  id             :bigint(8)        not null, primary key
#  date_birth     :date
#  date_death     :date
#  image_uid      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  crop_alignment :string           default("center")
#

class Person < ApplicationRecord
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
    default Rails.root.join('public','images','default-square-person.png')
  end

  #################
  ## ASSOCIATIONS ##
  #################
  has_many :person_roles, dependent: :destroy
  # has_many :illustrations, dependent: :nullify
  has_many :related_items, dependent: :nullify

  #################
  ## TRANSLATIONS ##
  #################
  translates :name, :first_name, :last_name, :bio, :is_public, :published_at, :slug, :versioning => :paper_trail
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
      [:first_name, :last_name],
      [:first_name, :last_name, :date_birth]
    ]
  end

  #################
  ## VALIDATION ##
  #################
  validates_size_of :image, maximum: 5.megabytes
  validates_property :ext, of: :image, in: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']

  #################
  ## CALLBACKS ##
  #################
  before_save :set_translation_published_at
  validate :check_self_public_required_fields
  # before_validation :remove_blanks

  #################
  ## SCOPES ##
  #################
  scope :published, -> { with_translations(I18n.locale).where('person_translations.is_public': true) }
  scope :sort_published_desc, -> { order(published_at: :desc) }
  scope :sort_name_asc, -> { select('people.*, person_translations.last_name, person_translations.first_name').with_translations(I18n.locale).order('person_translations.last_name asc, person_translations.first_name asc') }

  # search query for the list admin page
  # - first name
  # - last name
  def self.admin_search(q)
    ids = []

    people = self.with_translations(I18n.locale)
          .where(build_full_text_search_sql(%w(person_translations.first_name person_translations.last_name)),
            q
          ).pluck(:id)

    if people.present?
      ids << people
    end

    ids = ids.flatten.uniq

    if ids.present?
      self.where(id: ids).distinct
    else
      self.none
    end
  end

  def self.illustrator
    person_id = PersonRole.illustrators.pluck(:person_id).uniq
    self.where(id: person_id)
  end

  # get all people that are assigned to published illustrations
  def self.with_published_illustrations
    # get all published illustrations with a person role record
    illustration_ids = Illustration.published.where(id: PersonRole.where(person_roleable_type: 'Illustration').pluck(:person_roleable_id).uniq).pluck(:id).uniq
    if illustration_ids.present?
      self.where(id: PersonRole.where(person_roleable_type: 'Illustration', person_roleable_id: illustration_ids).pluck(:person_id)).distinct
    else
      return self
    end
  end

  # get all people that are assigned to published publications
  # - have to check both publication and publication editor roles
  def self.with_published_publications
    # get all role records assigned to a publication
    pub_roles = PersonRole.where(person_roleable_type: 'Publication')
    pub_editor_roles = PersonRole.where(person_roleable_type: 'PublicationEditor')

    publication_ids = []
    pub_editors = nil
    if pub_roles.present?
      # get publication ids
      publication_ids << pub_roles.map{|x| x.person_roleable_id}
    end
    if pub_editor_roles.present?
      # get publication ids from publication editor records
      pub_editors = PublicationEditor.where(id: pub_editor_roles.map{|x| x.person_roleable_id}).pluck(:id, :publication_id).uniq
      publication_ids << pub_editors.map{|x| x[1]}.uniq
    end
    # make sure we only have unique ids
    publication_ids = publication_ids.flatten.uniq

    # figure out which ones are published
    published_publication_ids = Publication.published.where(id: publication_ids).pluck(:id).uniq

    if published_publication_ids.present?
      # pull the person_id from the roles that are assigned to the published records
      person_ids = []
      if pub_roles.present?
        person_ids << pub_roles.select{|x| published_publication_ids.include?(x.person_roleable_id) }.map{|x| x.person_id}
      end
      if pub_editor_roles.present?
        published_pub_editors = pub_editors.select{|x| published_publication_ids.include?(x[1])}.uniq
        person_ids << pub_editor_roles.select{|x| published_pub_editors.include?(x.person_roleable_id) }.map{|x| x.person_id}
      end
      # make sure we only have unique ids
      person_ids = person_ids.flatten.uniq

      if person_ids.present?
        self.where(id: person_ids).distinct
      else
        self
      end
    else
      return self
    end
  end

  # get the min and max date values
  def self.date_ranges
    range = nil
    dates = self.published.pluck(:date_birth, :date_death).flatten.uniq.reject(&:blank?).sort
    if dates.present?
      range = {min: dates.first, max: dates.last}
    end

    return range
  end

  # filter people by the following:
  # - role - role id from person role model
  # - date_start - birth date is greater than this date
  # - date_end - death date is greater than this date
  # - search - string
  def self.filter(options={})
    x = self
    if options[:role].present?
      x = x.joins(:person_roles).where(person_roles: {role_id: options[:role]})
    end

    if options[:date_start].present?
      x = x.where('date_birth >= :start or date_death >= :start', start: options[:date_start])
    end

    if options[:date_end].present?
      x = x.where('date_birth <= :end or date_death <= :end', end: options[:date_end])
    end

    if options[:search].present?
      x = x.with_translations(I18n.locale)
            .where(build_full_text_search_sql(%w(person_translations.first_name person_translations.last_name person_translations.bio)),
              options[:search]
            )
    end

    return x.distinct
  end

  #################
  ## METHODS ##
  #################
  def name
    x = ''
    if self.first_name.present?
      x << self.first_name
      if self.last_name.present?
        x << ' '
        x << self.last_name
      end
    elsif self.last_name.present?
      x << self.last_name
    end

    return x
  end

  # go through person_roles with roleable type of Illustration
  # and then see how many are published
  def illustration_count
    total = nil
    illustration_ids = self.person_roles.where(person_roleable_type: 'Illustration').pluck(:person_roleable_id)

    if illustration_ids.present?
      total = Illustration.published.where(id: illustration_ids).count
    end

    return total
  end

  # go through person_roles with roleable type of Publication or PublicationEditor
  # and then see how many are published
  def publication_count
    total = nil
    publication_ids = self.person_roles.where(person_roleable_type: 'Publication').pluck(:person_roleable_id)
    pub_editor_ids = self.person_roles.where(person_roleable_type: 'PublicationEditor').pluck(:person_roleable_id)

    if pub_editor_ids.present?
      # get publication ids and add to publication_ids variable
      pub_ids = PublicationEditor.where(id: pub_editor_ids).pluck(:publication_id)
      if pub_ids.present?
        if !publication_ids.present?
          publication_ids = []
        end
        publication_ids << pub_ids
        publication_ids.flatten!
        publication_ids.uniq!
      end
    end

    if publication_ids.present?
      total = Publication.published.where(id: publication_ids).count
    end

    return total
  end

  def unique_role_names
    self.person_roles.unique_roles.map{|x| x[:name]}.sort
  end

  def has_dates?
    self.date_birth.present? || self.date_death.present?
  end

  def lived
    x = ''

    if self.has_dates?
      x << (self.date_birth.nil? ? '?' : I18n.l(self.date_birth))
      x << ' - '
      x << (self.date_death.nil? ? '?' : I18n.l(self.date_death))
    end

    return x
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.primary')

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 100

    # configuration
    configure :date_birth do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY-MM-DD', viewMode: 'years', minDate: '1800-01-01', maxDate: "#{Time.now.year}-12-31"
    end
    configure :date_death do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY-MM-DD', viewMode: 'years', minDate: '1800-01-01', maxDate: "#{Time.now.year}-12-31"
    end
    configure :bio do
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
      field :image
      field :first_name
      field :last_name
      field :date_birth
      field :date_death
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :published_at
      field :updated_at
    end

    # show page
    show do
      field :is_public
      field :image do
        thumb_method '150x'
      end
      field :crop_alignment
      field :first_name
      field :last_name
      field :bio
      field :date_birth
      field :date_death
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :published_at
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label I18n.t('labels.translations')
      end
      field :image do
        help "#{I18n.t('admin.help.image_size.person')} #{I18n.t('admin.help.image')}"
      end
      field :crop_alignment do
        help I18n.t('admin.help.crop_alignment')
      end
      field :date_birth
      field :date_death
    end
  end


  #################
  ## PRIVATE METHODS ##
  #################
  private

  def check_self_public_required_fields
    # call the methohd in the application record base object
    super(%w(first_name last_name bio))
  end
end
