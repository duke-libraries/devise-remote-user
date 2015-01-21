require 'devise/strategies/authenticatable'

module Devise

  module Strategies
    class RemoteUserAuthenticatable < Authenticatable

      def valid?
        remotely_authenticated? || remote_login_url?
      end

      def authenticate!
        if remotely_authenticated?
          resource = mapping.to.find_for_remote_user_authentication(env)
          resource ? success!(resource) : fail
        else
          redirect!(remote_login_url)
        end
      end

      private

      def remotely_authenticated?
        DeviseRemoteUser.remote_user_id(env).present?
      end

      def remote_login_url
        DeviseRemoteUser.login_url.call(env)
      rescue NoMethodError
        DeviseRemoteUser.login_url
      end

      def remote_login_url?
        DeviseRemoteUser.login_url.present?
      end

    end
  end
end

Warden::Strategies.add(:remote_user_authenticatable, Devise::Strategies::RemoteUserAuthenticatable)
