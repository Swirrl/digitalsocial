require 'raven'

# This file gets copied to shared/configs and linked from
# config/initializers/raven.rb at deployment by capistrano.

Raven.configure do |config|
  # Replace this URL with the one provided by getsentry.
  config.dsn = 'https://9ee5c448b2dc42be81448b502b164820:59004b5ea4b545f5af58d310a3802ea8@app.getsentry.com/12422'
end
