devise-remote-user
==================

A devise extension for remote user authentication.

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

- `env_var` - String (default: `'REMOTE_USER'`).  Request environment key for the remote user id.
- `attribute_map` - Hash (default: `{}`).  Map of User model attributes to request environment keys for updating the local user when auto-creation is enabled.
- `auto_create` - Boolean (default: `false`). Whether to auto-create a local user from the remote user attributes.  Note: Also requires adding the Warden callbacks as shown below.
- `auto_update` - Boolean (default: `false`). Whether to auto-update authenticated user attributes from remote user attributes.

Set options in a Rails initializer (e.g., `config/intializers/devise.rb`):

```ruby
require 'devise-remote-user'

DeviseRemoteUser.configure do |config|
  config.env_key = 'REMOTE_USER'
  config.auto_create = true
  config.auto_update = true
  config.attribute_map = {email: 'mail'}
end
```

## Tests

`rake spec` runs the test suite.
