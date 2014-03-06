# Be sure to restart your server when you modify this file.
#
# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# To generate a secure value for this value for production do the
# following:
#
# $ irb
#
# 1.9.3-p448 :001 > require 'securerandom'
# => true
# 1.9.3-p448 :002 > SecureRandom.hex(64)
# => "0677f2adfd6d181fd5d6abf4d047f526f57db7355705ab97624b08024622c94cf72d8e3a9469667df69feb916af4bab4dcefcecd7e0d103025ad92b007676acc"
#
# Then copy the random string into the secret_token, and copy this
# file to config/initializers/secret_token_production.rb .
#
# The capistrano setup task willl then copy this to the server in the
# shared/ directory within the app.

Digitalsocial::Application.config.secret_token = 'replace this value'
