# == Schema Information
#
# Table name: highlights
#
#  id              :bigint(8)        not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cover_image_uid :string
#

class Highlight < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  dragonfly_accessor :cover_image

  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :summary, :link, :is_public, :date_publish, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  validates_size_of :cover_image, maximum: 5.megabytes
  validates_property :ext, of: :cover_image, in: ['jpg', 'jpeg', 'png']

  #################
  ## CALLBACKS ##
  #################
  before_save :set_translation_publish_dates
  validate :check_self_public_required_fields

  #################
  ## SCOPES ##
  #################
  scope :published, -> { where(is_public: true) }
  scope :sort_published_desc, -> { order(date_publish: :desc) }

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.news')

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 300

    # configuration
    configure :summary do
      pretty_value do
        value.nil? ? nil : value.html_safe
      end
    end
    configure :link do
      pretty_value do
        if bindings[:object].link.present?
          bindings[:view].content_tag(:a, I18n.t('labels.view'),
              href: bindings[:object].link,
              target: :blank,
              class: 'btn btn-sm btn-default')
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
    configure :cover_image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end

    # list page
    list do
      field :is_public
      field :cover_image
      field :title
      field :summary
      field :link
    end

    # show page
    show do
      field :is_public
      field :cover_image
      field :title
      field :summary
      field :link
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :cover_image do
        help I18n.t('admin.help.image')
      end
      field :translations do
        label I18n.t('labels.translations')
      end
    end
  end

  #################
  ## PRIVATE METHODS ##
  #################
  private

  def check_self_public_required_fields
    # call the methohd in the application record base object
    super(%w(title summary link))
  end
end
