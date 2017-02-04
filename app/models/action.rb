# Auto generate with actionstore gem.
class Action < ActiveRecord::Base
  include ActionStore::Model

  # User `action_for` to define actions, for example:
  #
  # action_for :like, :post, counter_cache: true
  # action_for :star, :post
  # action_for :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'
end