require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

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


    # turn off activestorage routes - HACK
    ## NOTE - the routes are normally loaded through gem but
    #         the locale route scope causes a problem with that
    #         so removing them here and manually adding in routes file
   initializer(:remove_activestorage_routes, after: :add_routing_paths) {|app|
      app.routes_reloader.paths.delete_if {|path| path =~ /activestorage/}}

  end
end
