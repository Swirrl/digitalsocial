Digitalsocial::Application.configure do

  Digitalsocial::NOMINATIM_EMAIL = 'nominatim@digitalsocial.eu'

  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false # no caching yet!

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  config.assets.css_compressor = :yui # this requires java on the server. sudo apt-get install openjdk-6-jre
  config.assets.js_compressor = :yui

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( MarkerCluster.css leaflet.markercluster-src.js tree-view.js d3.min.js)

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.action_mailer.default_url_options = { host: 'digitalsocial.eu' }

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    :address              => "smtp.mandrillapp.com",
    :port                 => 587,
    :enable_starttls_auto => true,
    :user_name            => 'hello@swirrl.com',
    :password             => 'put your password here',
    :domain               => 'digitalsocial.eu',
    :authentication       => 'plain'
  }

  Digitalsocial::DATA_ENDPOINT = 'http://46.4.78.148/dsi/data'

  Tripod.configure do |config|
    config.update_endpoint = 'http://46.4.78.148/dsi/update'
    config.query_endpoint = 'http://46.4.78.148/dsi/sparql'
    config.timeout_seconds = 30
    config.cache_store = Tripod::CacheStores::MemcachedCacheStore.new('localhost:11214')
  end
end
