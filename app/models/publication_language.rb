class PublicationLanguage < ApplicationRecord

  # keep track of history (changes)
  has_paper_trail

  # translations
  translates :language
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  translation_class.validates :language, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    configure :translations, :globalize_tabs

    # list page
    list do
      field :language
      field :is_active
      field :created_at
      field :updated_at
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
        label "Translations"
      end
      field :is_active
    end
  end
end
