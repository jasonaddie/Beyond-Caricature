Rails.application.routes.draw do

  scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

    devise_for :users



    # default homepage
    root to: "home#index"

    # if there is no match, redirect to default locale home page
    match "*path", to: redirect("/#{I18n.default_locale}"), via: :all
  end

  match '', to: redirect("/#{I18n.default_locale}"), via: :all # handles /

  # have to turn the following off so activestorage urls work
  # match '*path', to: redirect("/#{I18n.default_locale}/%{path}"), via: :all # handles /not-a-locale/anything

end
