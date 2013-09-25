$:.push File.expand_path("../lib", __FILE__)

require "devise_remote_user/version"

Gem::Specification.new do |s|

  s.name        = "devise-remote-user"
  s.version     = DeviseRemoteUser::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Chandek-Stark"]
  s.email       = ["lib-drs@duke.edu"]
  s.homepage    = "http://github.com/duke-libraries/devise-remote-user"
  s.summary     = "A devise extension for remote user authentication."
  s.description = "A devise extension for remote user authentication."
  s.license     = "BSD"

  s.files = `git ls-files`.split("\n")
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.require_paths = ["lib"]
  s.add_dependency "rails", ">= 3.2"
  s.add_dependency "devise"
end