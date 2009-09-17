# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_jbrowsor_session',
  :secret      => 'ffc8c52f4fdfe74b88304d2083beb62c137e6564ee5f58b5afec2e14eaccc2ae23db31b03dc169bee2c0412f358082eefb724dea4736d8c5d8fe0ba9ca5a73c6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
