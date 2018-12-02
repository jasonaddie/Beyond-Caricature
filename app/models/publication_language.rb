# == Schema Information
#
# Table name: publication_languages
#
#  id         :bigint(8)        not null, primary key
#  is_active  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PublicationLanguage < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## TRANSLATIONS ##
  #################
  translates :language, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :language, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # make a parent for naviation
    navigation_label 'Supporting Data'

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 140

    # list page
    list do
      field :language
      field :is_active
    end

    # show page
    show do
      field :language
      field :is_active
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label I18n.t('labels.translations')
      end
      field :is_active
    end
  end
end
