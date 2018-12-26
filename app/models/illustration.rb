# == Schema Information
#
# Table name: illustrations
#
#  id             :bigint(8)        not null, primary key
#  illustrator_id :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  image_uid      :string
#

class Illustration < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  # has_one_attached :image
  # # have to add method to delete attached file
  # attr_accessor :remove_image
  # after_save { asset.purge if remove_image == '1' }
  dragonfly_accessor :image

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustrator
  has_many :illustration_tags, dependent: :destroy
  has_many :tags, through: :illustration_tags
  has_many :illustration_publications, dependent: :destroy
  has_many :publications, through: :illustration_publications
  # has_many :publications, through: :illustration_publications, -> { not_journals }, inverse_of: :illustrations

  has_many :illustration_issues, dependent: :destroy
  has_many :issues, through: :illustration_issues

  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :context, :is_public, :date_publish, :versioning => :paper_trail
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
  def publications_count
    self.illustration_publications.count
  end

  def issues_count
    self.illustration_issues.count
  end

  def combined_publications_count
    publications_count + issues_count
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # make a parent for naviation
    navigation_label 'Primary Data'

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 10

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
    # publication list should not show journals
    configure :publications do
      #TODO
    end
    configure :context do
      pretty_value do
        value.nil? ? nil : value.html_safe
      end
    end
    configure :image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end

    # list page
    list do
      field :is_public
      field :image
      field :title
      field :illustrator
      field :combined_publications_count do
        label I18n.t('labels.combined_publications_count')
      end
      field :date_publish
    end

    # show page
    show do
      field :is_public
      field :image
      field :title
      field :context
      field :illustrator
      field :combined_publications_count do
        label I18n.t('labels.combined_publications_count')
      end
      field :tags
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :image
      field :illustrator
      field :translations do
        label I18n.t('labels.translations')
      end
      field :publications
      field :issues
      field :tags
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
