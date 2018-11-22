# == Schema Information
#
# Table name: illustrators
#
#  id         :integer          not null, primary key
#  date_birth :date
#  date_death :date
#  is_public  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Illustrator < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  has_one_attached :image
  # have to add method to delete attached file
  attr_accessor :remove_image
  after_save { asset.purge if remove_image == '1' }

  #################
  ## ASSOCIATIONS ##
  #################
  has_many :illustrations, dependent: :nullify

  #################
  ## TRANSLATIONS ##
  #################
  translates :name, :bio
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :name, presence: true

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
        value.html_safe
      end
    end

    # list page
    list do
      field :image
      field :name
      field :date_birth
      field :date_death
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :is_public
    end

    # show page
    show do
      field :image
      field :name
      field :bio
      field :date_birth
      field :date_death
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :is_public
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
      field :is_public
    end
  end
end
