require 'devise/strategies/authenticatable'

module Devise

  module Strategies
    class RemoteUserAuthenticatable < Authenticatable

      def valid?
        DeviseRemoteUser.remote_user_id(env).present?
      end

      def authenticate!
        resource = mapping.to.find_for_remote_user_authentication(env)
        resource ? success!(resource) : fail
      end

    end
  end
end

Warden::Strategies.add(:remote_user_authenticatable, Devise::Strategies::RemoteUserAuthenticatable)
