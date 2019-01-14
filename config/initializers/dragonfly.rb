require 'dragonfly'
require 'dragonfly/s3_data_store'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret ENV['DRAGONFLY_SECRET_KEY']

  url_format "/media/:job/:name"

  if ENV['DRAGONFLY_USE_S3'] == 'true'
    datastore :s3,
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION'],
      bucket_name: ENV['AWS_BUCKET'],
      url_host: ENV['AWS_URL_HOST'],
      url_scheme: ENV['AWS_URL_SCHEME'],
      root_path: ENV['AWS_ROOT_PATH'],
      fog_storage_options: {
        endpoint: ENV['AWS_ENDPOINT']
      }
  else
    datastore :file,
      root_path: Rails.root.join('public/system/dragonfly', Rails.env),
      server_root: Rails.root.join('public')
  end

  # if the generated image exists,
  # pull from the datastore
  # else generate it
  define_url do |app, job, opts|
    thumb = Thumb.find_by_job(job.signature)
    if thumb
      app.datastore.url_for(thumb.uid, :scheme => 'https')
    else
      app.server.url_for(job)
    end
  end

  # save the different image versions
  # that are generated to file after
  # the image is generated
  before_serve do |job, env|
    uid = job.store
    ext = File.extname(uid).gsub('.', '')

    # only save the thumb if it is an image
    if (%w(jpg jpeg png).include?(ext))
      Thumb.create!(
          :uid => uid,
          :job => job.signature
      )
    end
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
