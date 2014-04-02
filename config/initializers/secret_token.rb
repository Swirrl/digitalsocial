Digitalsocial::Application.config.secret_token = if Rails.env.test? or Rails.env.development?
  ('x' * 30) # meets minimum requirement of 30 chars long
else
  # We expect this file to be overwritten by the capistrano script
  # during production deployments.
  raise StandardError, "You must provide and provision a Digitalsocial::Application.config.secret_token for this environment."
end
