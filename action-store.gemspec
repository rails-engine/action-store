# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "action_store/version"

Gem::Specification.new do |s|
  s.name        = "action-store"
  s.version     = ActionStore::VERSION
  s.date        = "2017-02-04"
  s.summary     = "Store difference kind of actions (Like, Follow, Star, Block ...) in one table."
  s.description = "Store difference kind of actions (Like, Follow, Star, Block ...) in one table via ActiveRecord Polymorphic Association."
  s.authors     = ["Jason Lee"]
  s.email       = "huacnlee@gmail.com"
  s.files       = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  s.homepage    = "https://github.com/rails-engine/action-store"
  s.license     = "MIT"

  s.add_dependency "rails", ">= 5.2", "< 7"

  s.add_development_dependency "codecov"
  s.add_development_dependency "factory_bot"
  s.add_development_dependency "pg"
  s.add_development_dependency "simplecov"
end
