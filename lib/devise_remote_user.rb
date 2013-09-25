require 'devise'

module DeviseRemoteUser
  class Engine < Rails::Engine
  end
end

module Devise
  # request.env key for remote user name
  # Set to 'HTTP_REMOTE_USER' in config/initializers/devise.rb if behind reverse proxy
  mattr_accessor :remote_user_env_key
  @@remote_user_env_key = 'REMOTE_USER'
  
  # Enable user auto-creation for remote user
  mattr_accessor :remote_user_autocreate
  @@remote_user_autocreate = false

  # User attribute used for lookup of remote user
  # Defaults to Devise.authentication_keys.first
  mattr_accessor :remote_user_auth_key
  @@remote_user_auth_key = nil

  # Map of User model attributes to request.env keys for updating a local user when auto-creation is enabled.
  mattr_accessor :remote_user_attribute_map
  @@remote_user_attribute_map = {}
end

Devise.add_module(:remote_user_authenticatable,
                  :strategy => true,
                  :controller => :sessions,
                  :model => 'devise_remote_user/model')
