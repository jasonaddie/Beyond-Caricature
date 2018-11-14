class News < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :summary, :text
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  translation_class.validates :title, presence: true
  translation_class.validates :text, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 300

    # list page
    list do
      field :title
      field :summmary
      field :is_public
      field :date_publish
    end

    # show page
    show do
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
        label "Translations"
      end
      field :date_publish
      field :is_public
    end
  end
end
