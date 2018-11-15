class Tag < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  has_many :illustration_tags, dependent: :destroy
  has_many :illustrations, through: :illustration_tags

  #################
  ## TRANSLATIONS ##
  #################
  translates :name
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
    weight 140

    # list page
    list do
      field :name
      field :illustration_count do
        label "Tagged Illustrations"
      end
    end

    # show page
    show do
      field :name
      field :illustration_count do
        label "Tagged Illustrations"
      end
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label "Translations"
      end
    end
  end
end
