# Auto generate with actionstore gem.
class Action < ActiveRecord::Base
  include ActionStore::Model

  # Write your custom methods...
  # allow_actions %w(like follow star)
end