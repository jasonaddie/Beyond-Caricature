Rails.application.routes.draw do

  ####################
  # rails_admin routes
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  ####################
  # ckeditor image upload routes
  mount Ckeditor::Engine => '/ckeditor'

  get '/robots.txt' => 'home#robots'

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
    get '/images', to: 'home#images', as: 'images'
    get '/images/:id', to: 'home#image', as: 'image'
    get '/people', to: 'home#people', as: 'people'
    get '/people/:id', to: 'home#person', as: 'person'
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
