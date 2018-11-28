# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  has_many :illustration_tags, dependent: :destroy
  has_many :illustrations, through: :illustration_tags

  #################
  ## TRANSLATIONS ##
  #################
  translates :name, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :name, presence: true

  #################
  ## METHODS ##
  #################
  def illustration_count
    self.illustration_tags.count
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 140

    # list page
    list do
      field :name
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
    end

    # show page
    show do
      field :name
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label I18n.t('labels.translations')
      end
    end
  end
end
