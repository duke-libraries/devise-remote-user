require 'devise'

module DeviseRemoteUser

  class Engine < Rails::Engine; end

  #
  # The UserManager class is responsible for connecting the appliation's User 
  # class with remote user information in the request environment.
  #
  # To implement auto-updating behavior, add to config/initializers/devise.rb
  #
  #      Warden::Manager.after_authentication do |user, auth, opts|
  #        user_manager = DeviseRemoteUser::UserManager.new(auth.env)
  #        user_manager.update_user(user)
  #      end
  #
  class UserManager

    attr_reader :env
    
    def initialize(env)
      @env = env
    end

    def remote_user_attributes
      Devise.remote_user_attribute_map.inject({}) { |h, (k, v)| h[k] = env[v] if env.has_key?(v); h }
    end

    def find_user
      User.where(user_criterion).first
    end

    def create_user
      random_password = SecureRandom.hex(16)
      attrs = user_criterion.merge({password: random_password, password_confirmation: random_password})
      user = User.create(attrs)
      update_user(user)
      user
    end

    def update_user(user)
      user.update_attributes(remote_user_attributes)
    end

    def user_criterion
      {auth_key => remote_user_id}
    end

    def remote_user_id
      env[Devise.remote_user_env_key]
    end

    def auth_key
      Devise.remote_user_auth_key || Devise.authentication_keys.first
    end
    
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
