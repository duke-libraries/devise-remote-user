devise-remote-user
==================

A devise extension for remote user authentication.

[![Gem Version](https://badge.fury.io/rb/devise-remote-user.svg)](http://badge.fury.io/rb/devise-remote-user)
[![Build Status](https://travis-ci.org/duke-libraries/devise-remote-user.svg?branch=master)](https://travis-ci.org/duke-libraries/devise-remote-user)
[![Coverage Status](https://coveralls.io/repos/duke-libraries/devise-remote-user/badge.png?branch=master)](https://coveralls.io/r/duke-libraries/devise-remote-user?branch=master)
[![Code Climate](https://codeclimate.com/github/duke-libraries/devise-remote-user/badges/gpa.svg)](https://codeclimate.com/github/duke-libraries/devise-remote-user)

## Installation

Add to Gemfile:

```
gem 'devise-remote-user'
```

Then

```
bundle install
```

Sorry, there are no generators yet, so ...

- Add `:remote_user_authenticatable` symbol to `devise` statement in User model, before other authentication strategies (e.g., `:database_authenticatable`).
- Add `before_filter :authenticate_user!` to ApplicationController, if not already present.  This ensures that remote user is logged in locally (via database)

Configuration options:

- `env_key` - String (default: `'REMOTE_USER'`).  Request environment key for the remote user id.
- `attribute_map` - Hash (default: `{}`).  Map of User model attributes to request environment keys for updating the local user when auto-creation is enabled.
- `auto_create` - Boolean (default: `false`). Whether to auto-create a local user from the remote user attributes.  Note: Also requires adding the Warden callbacks as shown below.
- `auto_update` - Boolean (default: `false`). Whether to auto-update authenticated user attributes from remote user attributes.
- `logout_url` - String (default: `'/'`).  For redirecting to a remote user logout URL after signing out of the Rails application.  Include `DeviseRemoteUser::ControllerBehavior` in your application controller to enable (by overriding Devise's `after_sign_out_path_for`).
- `user_model` - String (default: `'User'`). If your your user model differs from `User`.

Set options in a Rails initializer (e.g., `config/intializers/devise.rb`):

```ruby
require 'devise_remote_user'

DeviseRemoteUser.configure do |config|
  config.env_key = 'REMOTE_USER'
  config.auto_create = true
  config.auto_update = true
  config.attribute_map = {email: 'mail'}
  config.logout_url = "http://my.host/path.to.remote.logout"
  config.user_model = "User"
end
```

## Tests

`rake spec` runs the test suite.
