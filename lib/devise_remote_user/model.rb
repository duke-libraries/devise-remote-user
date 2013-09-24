require 'devise_remote_user/strategy'

module Devise::Models
  module RemoteUserAuthenticatable
    extend ActiveSupport::Concern

    module ClassMethods

      def find_for_remote_user_authentication(env)
        user = User.find_by_username(env[Devise.remote_user_env_key])
        if !user && Devise.remote_user_autocreate
          user = create_user!(env)
        end
        user
      end

      def create_user!(env)
        return nil unless Devise.remote_user_email_env_key.present? && env[Devise.remote_user_email_env_key].present?
        random_password = SecureRandom.hex(16)
        User.create!(:username => env[Devise.remote_user_env_key], 
                     :email => env[Devise.remote_user_email_env_key], 
                     :password => random_password, 
                     :password_confirmation => random_password)

      end

    end

  end
end
