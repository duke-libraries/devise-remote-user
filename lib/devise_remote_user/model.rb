require 'devise_remote_user/strategy'

module Devise::Models
  module RemoteUserAuthenticatable
    extend ActiveSupport::Concern

    module ClassMethods

      def find_for_remote_user_authentication(env)
        user = User.where(auth_key => remote_user_id(env)).first
        if !user && Devise.remote_user_autocreate
          user = create_user!(env)
        end
        user
      end

      private

      def auth_key
        Devise.remote_user_auth_key || self.authentication_keys.first
      end

      def create_user!(env)
        random_password = SecureRandom.hex(16)
        attrs = {
          auth_key => remote_user_id(env),
          :password => random_password,
          :password_confirmation => random_password
        }.merge(remote_user_attributes(env))
        User.create! attrs
      end

      def remote_user_id(env)
        env[Devise.remote_user_env_key]
      end

      def remote_user_attributes(env)
        Devise.remote_user_attribute_map.inject({}) { |h, (k, v)| h[k] = env[v] if env.has_key?(v); h }
      end

    end

  end
end
