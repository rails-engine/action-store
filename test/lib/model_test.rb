require 'test_helper'

class ActionStore::ModelTest < ActiveSupport::TestCase
  class Monkey < ActiveRecord::Base
    self.table_name = 'actions'
    include ActionStore::Model

    action_for :like, :post, counter_cache: true
    action_for :star, :post, counter_cache: true
    action_for :follow, :post
    action_for :like, :comment, counter_cache: true
    action_for :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'
  end

  test ".user" do
    monkey = Monkey.new
    assert_equal true, monkey.respond_to?(:user)
  end

  test ".target" do
    monkey = Monkey.new
    assert_equal true, monkey.respond_to?(:target)
  end

  test 'scopes' do
    assert_kind_of ActiveRecord::Relation, Monkey.likes
    assert_kind_of ActiveRecord::Relation, Monkey.follows
    assert_kind_of ActiveRecord::Relation, Monkey.stars
  end

  test ".allow_action?" do
    assert_equal true, Monkey.allow?(:like, :post)
    assert_equal true, Monkey.allow?('like', 'post')
    assert_equal true, Monkey.allow?(:follow, 'User')
    assert_equal true, Monkey.allow?(:star, 'post')
    assert_equal false, Monkey.allow?(:like, :user)
  end

  test ".create_action bas action_type" do
    a = Monkey.create_action(action_type: 'foobar')
    assert_equal false, a
    assert_equal 0, Monkey.count
  end

  test ".create_action" do
    post = create(:post)
    a = Monkey.create_action(action_type: 'like', target: post, user: post.user)
    assert_equal false, a.new_record?
    assert_equal 'like', a.action_type
    assert_equal post.id, a.target_id
    assert_equal 'Post', a.target_type
    assert_equal  post.user_id, a.user_id
    assert_equal 1, Monkey.likes.count

    b = Monkey.create_action(action_type: 'like', target: post, user: post.user)
    assert_equal false, b.new_record?
    assert_equal a.id, b.id

    c = Monkey.create_action(action_type: 'like', target_type: 'Post', target_id: post.id, user: post.user)
    assert_equal false, c.new_record?
    assert_equal a.id, c.id

    user1 = create(:user)
    a1 = Monkey.create_action(action_type: 'like', target: post, user: user1)
    assert_equal false, a1.new_record?
    assert_not_equal a.id, a1.id
    assert_equal 2, Monkey.likes.where(target: post).count

    a2 = Monkey.create_action(action_type: 'star', target: post, user: user1)
    assert_equal false, a2.new_record?
    assert_not_equal a.id, a2.id
    assert_not_equal a1.id, a2.id
    assert_equal 1, Monkey.stars.where(target: post).count

    a3 = Monkey.create_action(action_type: 'follow', target: post, user: user1)
    assert_equal false, a3.new_record?
    assert_not_equal a.id, a3.id
    assert_not_equal a1.id, a3.id
    assert_not_equal a2.id, a3.id
    assert_equal 1, Monkey.follows.where(target: post).count
  end
end
