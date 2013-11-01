class User < ActiveRecord::Base
  devise :remote_user_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
