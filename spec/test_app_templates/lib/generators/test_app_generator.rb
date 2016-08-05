require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root '../spec/test_app_templates'

  def add_devise
    gem 'devise'
    generate "devise:install"
    generate "devise", "User"
    rake 'db:migrate'
  end

  def add_devise_remote_user
    insert_into_file("app/models/user.rb", after: /^\s*devise /) do
      ":remote_user_authenticatable, "
    end

    insert_into_file("app/controllers/application_controller.rb", before: /end(\n| )*$/) do
      "\n  include DeviseRemoteUser::ControllerBehavior\n"
    end
  end

  def add_test_action
    insert_into_file("app/controllers/application_controller.rb", before: /end(\n| )*$/) do
      "\n  before_action :authenticate_user!\n" \
      "\n  def index; render plain: 'You have reached your destination!'; end\n"
    end
  end

  def add_user_metadata_migrations
    copy_file "20131101184256_add_name_fields_to_user.rb", "db/migrate/20131101184256_add_name_fields_to_user.rb"
    rake 'db:migrate'
  end
end
