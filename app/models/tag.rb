# == Schema Information
#
# Table name: tags
#
#  id         :bigint(8)        not null, primary key
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
  translates :name, :slug, :versioning => :paper_trail
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
      :name,
      [:name, :id]
    ]
  end

  #################
  ## VALIDATION ##
  #################
  # translation_class.validates :name, presence: true

  #################
  ## SCOPES ##
  #################
  scope :sort_name_asc, -> { select('tags.*, tag_translations.name').with_translations(I18n.locale).order('tag_translations.name asc') }

  # get all tags that are assigned to published illustrations
  def self.with_published_illustrations
    illustration_tags = IllustrationTag.all.pluck(:illustration_id, :tag_id)
    if illustration_tags.present?
      published_illustrations = Illustration.published.where(id: illustration_tags.map{|x| x[0]}).pluck(:id).uniq
      # if we have published illustrations, get the appropriate tags that are assigned to these illustrations
      if published_illustrations.present?
        where(id: illustration_tags.select{|x| published_illustrations.include?(x[0])}.map{|x| x[1]}.uniq)
      else
        self
      end
    else
      return self
    end
  end


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
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.supporting')

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 160

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
