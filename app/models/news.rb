# == Schema Information
#
# Table name: news
#
#  id           :integer          not null, primary key
#  date_publish :date
#  is_public    :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class News < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  has_one_attached :cover_image
  # have to add method to delete attached file
  attr_accessor :remove_cover_image
  after_save { asset.purge if remove_cover_image == '1' }

  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :summary, :text
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :title, presence: true
  # translation_class.validates :text, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 300

    # configuration
    configure :date_publish do
      date_format :default
      datepicker_options showTodayButton: true, format: 'YYYY-MM-DD'
    end
    configure :summary do
      pretty_value do
        value.html_safe
      end
    end
    configure :text do
      pretty_value do
        value.html_safe
      end
    end
    configure :cover_image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end

    # list page
    list do
      field :cover_image
      field :title
      field :summary
      field :is_public
      field :date_publish
    end

    # show page
    show do
      field :cover_image
      field :title
      field :summary
      field :text
      field :is_public
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label I18n.t('labels.translations')
      end
      field :cover_image
      field :is_public
      field :date_publish
    end
  end
end
