class PublicationLanguage < ApplicationRecord

  # keep track of history (changes)
  has_paper_trail

  #################
  ## VALIDATION ##
  #################
  validates :language, :presence => true


  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
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
      field :language
      field :is_active
    end
  end
end
