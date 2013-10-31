require 'devise/strategies/authenticatable'

module Devise

  module Strategies
    class RemoteUserAuthenticatable < Authenticatable

      def valid?
        env[DeviseRemoteUser.env_key].present?
      end

      def authenticate!
        resource = mapping.to.find_for_remote_user_authentication(env)
        resource ? success!(resource) : fail
      end

    end
  end
end

Warden::Strategies.add(:remote_user_authenticatable, Devise::Strategies::RemoteUserAuthenticatable)
