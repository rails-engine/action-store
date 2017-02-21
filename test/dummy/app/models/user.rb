class User < ActiveRecord::Base
  action_store :like, :post, counter_cache: true
  action_store :star, :post, counter_cache: true, user_counter_cache: true
  action_store :follow, :post
  action_store :like, :api__v1__comment, counter_cache: true
  action_store :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'
end