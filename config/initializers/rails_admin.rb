RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  config.show_gravatar = false


  config.browser_validations = false

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete do
      except ['User']
    end
    show_in_app

    ## With an audit adapter, you can add:
    history_index
    history_show
  end


  # show all fields in show page, even if empty
  config.compact_show_view = false

  # add fields that should be used by default to get the 'name'
  # - used in drop downs, etc
  # - default is title and name
  config.label_methods << :language

  # list all models to include in admin section
  # - have to include all translation models too
  config.included_models = [
    'User',
    'PublicationLanguage','PublicationLanguage::Translation',
    'Illustrator', 'Illustrator::Translation',
    'News', 'News::Translation',
    'Research', 'Resaerch::Translation',
    'Tag', 'Tag::Translation',
    'Illustration', 'Illustration::Translation',
    'Publication', 'Publication::Translation',
    'Issue'
  ]

  config.model 'PublicationLanguage::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :language
  end

  config.model 'Illustrator::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :name, :bio
  end

  config.model 'News::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :title, :summary, :text
  end

  config.model 'Research::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :title, :summary, :text
  end

  config.model 'Tag::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :name
  end

  config.model 'Illustration::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :title, :context
  end

  config.model 'Publication::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :title, :about, :editor, :publisher, :writer
  end
end
