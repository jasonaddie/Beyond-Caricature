source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'

# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 3.5', '>= 3.5.5'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', '~> 0.2.4', platforms: :ruby

# use react components
gem 'react_on_rails', '~> 11.1', '>= 11.1.8'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.9', '>= 4.9.2'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# admin interface
gem 'rails_admin', '~> 1.4', '>= 1.4.2'

# rails admin theming
gem 'rails_admin_material', '~> 0.2.1'

# authentication
gem 'devise', '~> 4.2'

# authorization
gem 'cancancan', '~> 2.3'

# transaction history
gem 'paper_trail', '~> 10.0', '>= 10.0.1'
gem 'paper_trail-association_tracking'

# translations
gem 'globalize', '~> 5.2'

# versioning with globalize and papertrail
gem 'globalize-versioning', '~> 0.3.0'

# manage locale files
gem 'i18n-tasks', '~> 0.9.28'

# translation tabs in forms
gem 'rails_admin_globalize_field', '~> 0.4.0'

# wysiwyg editor
gem 'ckeditor', github: 'galetahub/ckeditor'

# to connect to digitalocean spaces
# gem "aws-sdk-s3", require: false

# postgres db
gem 'pg', '~> 0.18.4'

# image storage / processing
gem 'dragonfly', '~> 1.2'
# store images on s3
gem 'dragonfly-s3_data_store', '~> 1.3'

# create permalinks
gem 'friendly_id', '~> 5.2', '>= 5.2.5'

# create permalinks with globalize
gem 'friendly_id-globalize', '~> 1.0.0.alpha3'

# convert utf to ascii for url slugs
gem 'stringex', '~> 2.8', '>= 2.8.5'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'dotenv-rails', '~> 2.6'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # add comments at top of model files of which fields are in the model
  gem 'annotate', '~> 2.7', '>= 2.7.4'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
