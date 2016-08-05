require 'devise'
require 'devise_remote_user/engine'
require 'devise_remote_user/controller_behavior'

module DeviseRemoteUser
  class << self
    attr_accessor :env_key, :auto_create, :auto_update, :auth_key, :attribute_map, :logout_url
  end

  # request.env key for remote user name
  # Set to 'HTTP_REMOTE_USER' in config/initializers/devise.rb if behind reverse proxy
  self.env_key = 'REMOTE_USER'

  # Enable user auto-creation of user from remote user attributes
  self.auto_create = false

  # Enable user auto-update of user attributes from remote user attributes
  self.auto_update = false

  # User attribute used for lookup of remote user
  # Defaults to Devise.authentication_keys.first
  self.auth_key = nil

  # Map of User model attributes to request.env keys for updating a local user when auto-creation is enabled.
  self.attribute_map = {}

  # Settings for redirecting to the remote user logout URL
  # Enable by including DeviseRemoteUser::Controllers::Helpers in ApplicationController
  # (it overrides Devise's after_sign_out_path_for method).
  self.logout_url = '/'


  def self.configure
    yield self
  end
  
  def self.remote_user_id env
    case env_key
    when Proc
      env_key.call(env)
    else
      env[env_key]
    end
  end

end

Devise.add_module(:remote_user_authenticatable,
                  :strategy => true,
                  :controller => :sessions,
                  :model => 'devise_remote_user/model')
