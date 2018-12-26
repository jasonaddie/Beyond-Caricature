# == Schema Information
#
# Table name: illustrators
#
#  id         :bigint(8)        not null, primary key
#  date_birth :date
#  date_death :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image_uid  :string
#

class Illustrator < ApplicationRecord
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
  has_many :illustrations, dependent: :nullify

  #################
  ## TRANSLATIONS ##
  #################
  translates :name, :bio, :is_public, :date_publish, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  validates_size_of :image, maximum: 5.megabytes
  validates_property :ext, of: :image, in: ['jpg', 'jpeg', 'png']

  #################
  ## CALLBACKS ##
  #################
  before_save :set_translation_publish_dates
  validate :check_self_public_required_fields

  #################
  ## METHODS ##
  #################
  def illustration_count
    self.illustrations.count
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # group with illustrations in navigation
    parent Illustration

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

    # list page
    list do
      field :is_public
      field :image
      field :name
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
      field :image
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
