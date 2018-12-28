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

    # default homepage
    root to: "home#index"

    # if there is no match, redirect to default locale home page
    match "*path", to: redirect("/#{I18n.default_locale}"), via: :all
  end

  match '', to: redirect("/#{I18n.default_locale}"), via: :all # handles /

  match '*path', to: redirect("/#{I18n.default_locale}/%{path}"), via: :all # handles /not-a-locale/anything


end
