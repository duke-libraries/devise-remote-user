module DeviseRemoteUser
  module ControllerBehavior

    def after_sign_out_path_for(resource_or_scope)
      return DeviseRemoteUser.logout_url if remote_user_authenticated? and DeviseRemoteUser.logout_url
      super
    end

    private 

    def remote_user_authenticated?
      request.env[DeviseRemoteUser.env_key].present?
    end

  end
end
