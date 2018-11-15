class Issue < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :publication, -> { journals }, inverse_of: :issues

  #################
  ## VALIDATION ##
  #################
  validates :issue_number, presence: true
  validates :date_publication, presence: true

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # control the order in the admin nav menu
    weight 30

    # configuration
    configure :date_publish do
      date_format :default
      datepicker_options showTodayButton: true, format: 'YYYY-MM-DD'
    end
    configure :date_publication do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY-MM-DD', viewMode: 'decades'
    end
    configure :publication do
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:publication).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
      end
    end

    # list page
    list do
      field :publication
      field :issue_number
      field :date_publication
      field :is_public
      field :date_publish
    end

    # show page
    show do
      field :publication
      field :issue_number
      field :date_publication
      field :is_public
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :publication
      field :issue_number
      field :date_publication
      field :is_public
      field :date_publish
    end
  end

end
