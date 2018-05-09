begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

task default: :ci

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'engine_cart/rake_task'

task ci: ['engine_cart:generate', 'spec']
