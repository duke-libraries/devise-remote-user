require 'devise_remote_user/strategy'

module Devise::Models
  module RemoteUserAuthenticatable
    extend ActiveSupport::Concern

    module ClassMethods

      def find_for_remote_user_authentication(env)
        user_manager = DeviseRemoteUser::UserManager.new(env)
        user = user_manager.find_user
        if !user && Devise.remote_user_autocreate
          user = user_manager.create_user
        end
        user
      end

    end

  end
end
