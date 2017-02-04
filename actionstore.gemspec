$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'action_store/version'

Gem::Specification.new do |s|
  s.name        = 'actionstore'
  s.version     = ActionStore::VERSION
  s.date        = '2017-02-04'
  s.summary     = "Store difference kind of actions (Like, Follow, Star, Block ...) in one table."
  s.description = "Store difference kind of actions (Like, Follow, Star, Block ...) in one table via ActiveRecord Polymorphic Association."
  s.authors     = ["Jason Lee"]
  s.email       = 'huacnlee@gmail.com'
  s.files       = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md', 'CHANGELOG']
  s.homepage    = 'https://github.com/rails-engine/actionstore'
  s.license     = 'MIT'

  s.add_dependency 'rails', '>= 4.2.0', '< 5.1'
end