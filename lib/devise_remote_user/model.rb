require 'devise_remote_user/strategy'
require 'devise_remote_user/manager'

module Devise::Models
  module RemoteUserAuthenticatable
    extend ActiveSupport::Concern

    module ClassMethods

      def find_for_remote_user_authentication(env)
        manager = DeviseRemoteUser::Manager.new(env)
        manager.find_or_create_user
      end

    end

  end
end
