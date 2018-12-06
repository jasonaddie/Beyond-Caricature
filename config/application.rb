require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# set the theme for rails admin
ENV['RAILS_ADMIN_THEME'] = 'material'

module BeyondCaricature
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.


    config.assets.paths << Rails.root.join("app", "assets", "fonts")


    # locales
    I18n.available_locales = [:az, :hy, :en, :ka, :ru]
    config.i18n.default_locale = :en
    config.time_zone = 'Tbilisi'

  end
end
