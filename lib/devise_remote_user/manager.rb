module DeviseRemoteUser

  #
  # The Manager class is responsible for connecting the appliation's User
  # class with remote user information in the request environment.
  #
  class Manager

    attr_reader :klass, :env

    def initialize(klass, env)
      @klass = klass
      @env = env
    end

    def find_or_create_user
      user = find_user
      if !user && DeviseRemoteUser.auto_create
        user = create_user
      end
      update_user(user) if user && DeviseRemoteUser.auto_update
      user
    end

    def find_user
      klass.where(user_criterion).first
    end

    def create_user
      random_password = SecureRandom.hex(16)
      attrs = user_criterion.merge({password: random_password, password_confirmation: random_password})
      klass.create(attrs)
    end

    def update_user(user)
      user.update_attributes(remote_user_attributes)
    end

    protected

    def remote_user_attributes
      DeviseRemoteUser.attribute_map.inject({}) { |h, (k, v)| h[k] = env[v] if env.has_key?(v); h }
    end

    def user_criterion
      {auth_key => remote_user_id}
    end

    def remote_user_id
      DeviseRemoteUser.remote_user_id(env)
    end

    def auth_key
      DeviseRemoteUser.auth_key || Devise.authentication_keys.first
    end

  end

end
