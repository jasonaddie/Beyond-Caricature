require_relative 'boot'

# instead of require rails/all,
# load just the pieces we need
# (not need activestorage)
# require 'rails/all'
%w(
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  rails/test_unit/railtie
  sprockets/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

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
    I18n.available_locales = [:az, :en, :hy, :ka, :ru]
    config.i18n.default_locale = :en
    config.time_zone = 'Tbilisi'

    # set the default url option of locale here so
    # middleware that creates links knows what locale to use
    config.after_initialize do
       Rails.application.routes.default_url_options[:locale] = I18n.default_locale
    end
  end
end
