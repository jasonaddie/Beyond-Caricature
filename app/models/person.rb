# == Schema Information
#
# Table name: people
#
#  id         :bigint(8)        not null, primary key
#  roles      :integer          default([]), not null, is an Array
#  date_birth :date
#  date_death :date
#  image_uid  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Person < ApplicationRecord
  extend ArrayEnum

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
  has_many :person_roles, as: :person_roleable, dependent: :destroy
  has_many :illustrations, dependent: :nullify
  has_many :related_items, dependent: :nullify

  #################
  ## TRANSLATIONS ##
  #################
  translates :name, :bio, :is_public, :date_publish, :slug, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## SLUG
  #################
  extend FriendlyId
  friendly_id :name, use: [:globalize, :history, :slugged]

  # override to use all locales and not the locales that exist in the
  # translation record
  # from: https://github.com/norman/friendly_id-globalize/blob/master/lib/friendly_id/globalize.rb
  def set_slug(normalized_slug = nil)
    (I18n.available_locales.presence || [::Globalize.locale]).each do |locale|
      ::Globalize.with_locale(locale) { super_set_slug(normalized_slug) }
    end
  end

  # override to test if the base value (i.e., name) is present and if so, generate slug
  # from: https://github.com/norman/friendly_id-globalize/blob/master/lib/friendly_id/globalize.rb
  def should_generate_new_friendly_id?
    send("#{friendly_id_config.base}_translations")[::Globalize.locale.to_s].present? && translation_for(::Globalize.locale).send(friendly_id_config.slug_column).nil?
  end


  # for locale sensitive transliteration with friendly_id
  def normalize_friendly_id(input)
    input.to_s.to_url
  end

  #################
  ## SCOPES ##
  #################
  def self.roles_for_select
    options = {}
    ROLES.each do |key, value|
      options[I18n.t("activerecord.attributes.#{model_name.i18n_key}.role_types.#{key}")] = key
    end
    return options
  end

  #################
  ## VALIDATION ##
  #################
  validates_size_of :image, maximum: 5.megabytes
  validates_property :ext, of: :image, in: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']
  validates :roles, presence: true, subset: %w(illustrator editor publisher writer printer financier official subject)

  #################
  ## CALLBACKS ##
  #################
  before_save :set_translation_publish_dates
  validate :check_self_public_required_fields
  # before_validation :remove_blanks

  # def remove_blanks
  #   Rails.logger.debug "===================="
  #   Rails.logger.debug "roles was #{roles.inspect}"
  #   roles.reject!(&:blank?)
  #   Rails.logger.debug "roles now #{roles.inspect}"
  #   Rails.logger.debug "===================="
  # end

  #################
  ## ENUMS ##
  #################
  ROLES = {'illustrator' => 1, 'editor' => 2, 'publisher' => 3, 'writer' => 4, 'printer' => 5, 'financier' => 6, 'official' => 7, 'subject' => 8}
  array_enum roles: ROLES

  #################
  ## SCOPES ##
  #################
  scope :published, -> { with_translations(I18n.locale).where('person_translations.is_public': true) }
  scope :sort_published_desc, -> { order(date_publish: :desc) }
  scope :sort_name, -> { with_translations(I18n.locale).order('person_translations.name asc') }

  #################
  ## METHODS ##
  #################
  def illustration_count
    self.illustrations.count
  end

  # show the translated name of the enum value
  def roles_formatted
    x = []
    if self.roles.present?
      self.roles.each do |role|
        x << I18n.t("activerecord.attributes.#{model_name.i18n_key}.role_types.#{role}")
      end
    end

    return x.present? ? x.join(', ') : nil
  end

  # this is used when loading the person form so the correct existing roles
  # are selected
  def roles_keys
    self.roles
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
    configure :roles do
      pretty_value do
        bindings[:object].roles_formatted
      end
    end

    # list page
    list do
      field :is_public
      field :image
      field :name
      field :roles
      field :date_birth
      field :date_death
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :date_publish
    end

    # show page
    show do
      field :is_public
      field :image
      field :name
      field :roles
      field :bio
      field :date_birth
      field :date_death
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label I18n.t('labels.translations')
      end
      field :image do
        help I18n.t('admin.help.image')
      end
      field :roles, :array_field do
        options_for_select Person.roles_for_select
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
    super(%w(name bio))
  end
end
