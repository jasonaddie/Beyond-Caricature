Rails.application.routes.draw do

  ####################
  # rails_admin routes
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  ####################
  # ckeditor image upload routes
  mount Ckeditor::Engine => '/ckeditor'

  ####################
  # have locale in url
  scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

    devise_for :users, :controllers => { :registrations => 'users/registrations' }

    # if url is admin, redirect to url with locale as querystring param
    match "/admin", to: redirect("/admin?locale=#{I18n.locale}"), via: :all

    # public pages
    get '/sources', to: 'home#sources', as: 'sources'
    get '/sources/:id', to: 'home#source', as: 'source'
    get '/sources/:publication_id/issue/:id', to: 'home#issue', as: 'issue'
    get '/illustrations', to: 'home#illustrations', as: 'illustrations'
    get '/illustrations/:id', to: 'home#illustration', as: 'illustration'
    get '/illustrators', to: 'home#illustrators', as: 'illustrators'
    get '/illustrators/:id', to: 'home#illustrator', as: 'illustrator'
    get '/news', to: 'home#news', as: 'news_index'
    get '/news/:id', to: 'home#news_item', as: 'news'
    get '/research', to: 'home#researches', as: 'researches'
    get '/research/:id', to: 'home#research', as: 'research'
    get '/about', to: 'home#about', as: 'about'


    # default homepage
    root to: "home#index"

    # if there is no match, redirect to default locale home page
    match "*path", to: redirect("/#{I18n.default_locale}"), via: :all
  end

  match '', to: redirect("/#{I18n.default_locale}"), via: :all # handles /

  match '*path', to: redirect("/#{I18n.default_locale}/%{path}"), via: :all # handles /not-a-locale/anything


end
