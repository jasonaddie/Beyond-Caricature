require 'dragonfly'
require 'dragonfly/s3_data_store'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret Rails.application.credentials.dig(:dragonfly, :secret)

  url_format "/media/:job/:name"

  if Rails.env.development?
    datastore :file,
      root_path: Rails.root.join('public/system/dragonfly', Rails.env),
      server_root: Rails.root.join('public')
  else
    datastore :s3,
      access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
      region: Rails.application.credentials.dig(:aws, :region),
      bucket_name: Rails.application.credentials.dig(:aws, :bucket),
      url_host: Rails.application.credentials.dig(:aws, :url_host),
      url_scheme: Rails.application.credentials.dig(:aws, :url_scheme),
      root_path: Rails.application.credentials.dig(:aws, :root_path),
      fog_storage_options: {
        endpoint: Rails.application.credentials.dig(:aws, :endpoint)
      }
  end
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
ActiveSupport.on_load(:active_record) do
  extend Dragonfly::Model
  extend Dragonfly::Model::Validations
end
