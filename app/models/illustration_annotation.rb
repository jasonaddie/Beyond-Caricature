class IllustrationAnnotation < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustration

  #################
  ## TRANSLATIONS ##
  #################
  translates :annotation, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  validates :sort, presence: true

  #################
  ## SCOPES ##
  #################
  def self.sorted
    order(sort: :asc, id: :asc)
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    visible false

    # group with illustrations in navigation
    parent Illustration

    configure :translations, :globalize_tabs

    # configuration

    # list page

    # show page

    # form
    edit do
      field :sort, :hidden do
        html_attributes class: 'sort-hidden-input'
      end
      field :translations do
        label I18n.t('labels.translations')
      end
    end
  end
end
