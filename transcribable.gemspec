$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "transcribable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "transcribable"
  s.version     = Transcribable::VERSION
  s.authors     = ["Al Shaw"]
  s.email       = ["almshaw@gmail.com"]
  s.homepage    = "https://github.com/propublica/transcribable"
  s.summary     = "Drop in crowdsourcing for your Rails app."
  s.description = "Drop in crowdsourcing for your Rails app."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2.0"
  s.add_dependency "rest-client"
  s.add_dependency "uuid"

  s.add_development_dependency "sqlite3"
end
