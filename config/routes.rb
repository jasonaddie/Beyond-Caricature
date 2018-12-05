Rails.application.routes.draw do

  ####################
  # rails_admin routes
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  ####################
  # activestorage routes - HACK
  ## NOTE - they are normally loaded through gem but
  #         the locale scope causes a problem with that
  #         so listing them all here
  get "/rails/active_storage/blobs/:signed_id/*filename" => "active_storage/blobs#show", as: :rails_service_blob

  direct :rails_blob do |blob, options|
    route_for(:rails_service_blob, blob.signed_id, blob.filename, options)
  end

  resolve("ActiveStorage::Blob")       { |blob, options| route_for(:rails_blob, blob, options) }
  resolve("ActiveStorage::Attachment") { |attachment, options| route_for(:rails_blob, attachment.blob, options) }


  get "/rails/active_storage/representations/:signed_blob_id/:variation_key/*filename" => "active_storage/representations#show", as: :rails_blob_representation

  direct :rails_representation do |representation, options|
    signed_blob_id = representation.blob.signed_id
    variation_key  = representation.variation.key
    filename       = representation.blob.filename

    route_for(:rails_blob_representation, signed_blob_id, variation_key, filename, options)
  end

  resolve("ActiveStorage::Variant") { |variant, options| route_for(:rails_representation, variant, options) }
  resolve("ActiveStorage::Preview") { |preview, options| route_for(:rails_representation, preview, options) }


  get  "/rails/active_storage/disk/:encoded_key/*filename" => "active_storage/disk#show", as: :rails_disk_service
  put  "/rails/active_storage/disk/:encoded_token" => "active_storage/disk#update", as: :update_rails_disk_service
  post "/rails/active_storage/direct_uploads" => "active_storage/direct_uploads#create", as: :rails_direct_uploads


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
