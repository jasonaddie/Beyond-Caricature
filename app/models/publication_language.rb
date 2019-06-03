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
  translates :language, :slug, :versioning => :paper_trail
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
      :language,
      [:language, :id]
    ]
  end

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :language, presence: true

  #################
  ## SCOPES ##
  #################
  scope :published, -> { where(is_active: true) }
  scope :sort_language_asc, -> { with_translations(I18n.locale).order('publication_language_translations.language asc') }

  def self.with_published_publications
    self.where(id: Publication.published.pluck(:publication_language_id).uniq)
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.supporting')

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
