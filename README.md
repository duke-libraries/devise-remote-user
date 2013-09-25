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

- Add `:remote_user_authenticatable` symbol to `devise` statement in User model.
- Add `require 'devise-remote-user' to devise initializer at `config/initializers/devise.rb`
- Add `before_filter :authenticate_user!` to ApplicationController, if not already present.  This ensures that remote user is logged in locally (via database)

Configuration options in `config/intializers/devise.rb`:

`remote_user_autocreate` - Boolean (default: false). Whether to auto-create a local user for the remote user.
`remote_user_env_var` - String (default: 'REMOTE_USER').  Request environment key for the remote user id.
`remote_user_attribute_map` - Hash (default: {}).  Map of User model attributes to request environment keys for updating the local user when auto-creation is enabled.

