require 'test_helper'

class ActionStore::MixinTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @user1 = create(:user)
    @post = create(:post)
    @post1 = create(:post)
  end

  test ".find_defined_action" do
    assert_not_equal nil, User.find_defined_action(:like, :post)
    assert_not_equal nil, User.find_defined_action('like', 'post')
    assert_not_equal nil, User.find_defined_action(:follow, 'User')
    assert_not_equal nil, User.find_defined_action(:star, 'post')
    assert_nil User.find_defined_action(:like, :user)

    defined_action = User.find_defined_action(:like, :post)
    assert_equal('like', defined_action[:action_type])
    assert_equal('post', defined_action[:action_name])
    assert_equal(Post, defined_action[:target_klass])
    assert_equal('likes_count', defined_action[:counter_cache])

    defined_action = User.find_defined_action(:follow, :user)
    assert_equal('follow', defined_action[:action_type])
    assert_equal('user', defined_action[:action_name])
    assert_equal(User, defined_action[:target_klass])
    assert_equal('followers_count', defined_action[:counter_cache])
    assert_equal('following_count', defined_action[:user_counter_cache])

    defined_action = User.find_defined_action(:follow, :post)
    assert_equal('follow', defined_action[:action_type])
    assert_equal('post', defined_action[:action_name])
    assert_equal(Post, defined_action[:target_klass])
    assert_nil(defined_action[:counter_cache])
    assert_nil(defined_action[:user_counter_cache])
  end

  test ".create_action bas action_type" do
    a = User.create_action('foobar', {})
    assert_equal false, a
    assert_equal 0, Action.count
  end

  test ".create_action" do
    post = create(:post)
    assert_equal true, User.create_action('like', target: post, user: post.user)
    a = User.find_action('like', target: post, user: post.user)
    assert_equal 'like', a.action_type
    assert_equal 'Post', a.target_type
    assert_equal post.id, a.target_id
    assert_equal  'User', a.user_type
    assert_equal  post.user_id, a.user_id
    assert_equal 1, Action.where(action_type: 'like', target_type: 'Post').count
    post.reload
    assert_equal 1, post.likes_count

    assert_equal true, User.create_action('like', target: post, user: post.user, action_option: 'aaa')
    a_with_option = User.find_action('like', target: post, user: post.user, action_option: 'aaa')
    assert_equal 'aaa', a_with_option.action_option
    assert_equal 1, Action.where(action_type: 'like', target_type: 'Post', action_option: 'aaa').count

    assert_equal true, User.create_action('like', target: post, user: post.user)
    assert_equal a.id, Action.last.id

    c = User.create_action('like', target_type: 'Post', target_id: post.id, user: post.user)
    assert_equal a.id, Action.last.id

    user1 = create(:user)
    assert_equal true, User.create_action('like', target: post, user: user1)
    a1 = Action.last
    assert_equal false, a1.new_record?
    assert_not_equal a.id, a1.id
    assert_equal 2, Action.where(action_type: 'like', target: post).count
    post.reload
    assert_equal 2, post.likes_count

    assert_equal true, User.create_action('star', target: post, user: user1)
    a2 = Action.last
    assert_equal false, a2.new_record?
    assert_not_equal a.id, a2.id
    assert_not_equal a1.id, a2.id
    assert_equal 1, Action.where(action_type: 'star', target: post).count
    post.reload
    assert_equal 1, post.stars_count

    assert_equal true, User.create_action('follow', target: post, user: user1)
    a3 = Action.last
    assert_equal false, a3.new_record?
    assert_not_equal a.id, a3.id
    assert_not_equal a1.id, a3.id
    assert_not_equal a2.id, a3.id
    assert_equal 1, Action.where(action_type: 'follow', target: post).count
  end

  test ".destroy_action" do
    u1 = create(:user)
    u2 = create(:user)
    u3 = create(:user)
    u4 = create(:user)

    # all user -> follow u2
    action = User.create_action('follow', target: u2, user: u1)
    assert_not_nil(action)
    User.create_action('follow', target: u2, user: u3)
    User.create_action('follow', target: u2, user: u4)
    assert_equal(3, u2.reload.followers_count)
    assert_equal(1, u1.reload.following_count)
    assert_equal(1, u3.reload.following_count)
    assert_equal(1, u4.reload.following_count)
    User.destroy_action('follow', target: u2, user: u3)
    User.destroy_action('follow', target: u2, user: u4)
    assert_equal(1, u2.reload.followers_count)
    assert_equal(0, u3.reload.following_count)
    assert_equal(0, u4.reload.following_count)

    # u2 -> follow -> u1
    action = User.create_action('follow', target: u1, user: u2)
    assert_not_nil(action)
    assert_equal(1, u2.reload.following_count)
    assert_equal(1, u1.reload.followers_count)
  end

  test ".destroy_action with not found work" do
    assert_equal true, User.destroy_action('follow', target_type: 'Post', target_id: -1, user: create(:user))
  end

  test ".find_action" do
    user = create(:user)
    post = create(:post)
    assert_equal true, User.create_action('like', target: post, user: user)
    result = User.find_action('like', target: post, user: user)
    assert_not_nil result
    result = User.find_action('like', target_type: 'Post', target_id: post.id, user: user)
    assert_not_nil result
  end

  test "Instance create_action, find_action, destoy_action" do
    user = create(:user)
    post = create(:post)

    assert_equal true, user.create_action(:like, target: post)
    assert_not_nil user.find_action(:like, target: post)
    assert_equal 1, user.like_posts.count
    assert_equal true, user.destroy_action(:like, target: post)
    assert_nil user.find_action(:like, target: post)
    assert_equal 0, user.like_posts.count
  end

  test "Base extension methods" do
    assert_equal true, @user.respond_to?(:like_post_actions)
    assert_equal true, @user.respond_to?(:like_posts)
    assert_equal true, @user.respond_to?(:follow_user_actions)
    assert_equal true, @user.respond_to?(:follow_users)
    assert_equal true, @user.respond_to?(:follow_by_user_actions)
    assert_equal true, @user.respond_to?(:follow_by_users)
    assert_equal true, @user.respond_to?(:like_post_ids)
    assert_equal true, @user.respond_to?(:like_post)
    assert_equal true, @user.respond_to?(:unlike_post)
  end

  test "like_post" do
    action = @user.like_post(@post)
    assert_not_equal false, action
    action1 = @user.like_post(@post1)
    assert_equal 2, @user.like_post_actions.length
    assert_equal 2, @user.like_posts.length
    assert_equal true, @user.like_post_ids.include?(@post.id)
    assert_equal true, @user.like_posts.exists?(@post.id)
    assert_equal true, @user.like_posts.exists?(@post1.id)

    # unlike
    action1 = @user.unlike_post(@post1)
    assert_not_equal false, action1
    assert_equal 1, @user.like_post_actions.length
    assert_equal 1, @user.like_post_ids.length
    assert_equal false, @user.like_post_ids.include?(@post1.id)
    assert_equal false, @user.like_posts.exists?(@post1.id)
  end

  test "follow_user" do
    action = @user.follow_user(@user1)
    assert_not_equal false, action
    assert_equal 1, @user.follow_user_actions.length
    assert_equal 1, @user1.follow_by_user_actions.length
    assert_equal 1, @user.follow_users.length
    assert_equal 1, @user1.follow_by_users.length
    assert_equal true, @user.follow_users.exists?(@user1.id)
    assert_equal true, @user1.follow_by_users.exists?(@user.id)
  end

  test "@user.has_many :like_post_actions / @post.has_many :like_user_actions" do
    action = @user.like_post(@post)
    assert_not_equal false, action

    assert_equal 1, @user.like_post_actions.length
    assert_kind_of Action, @user.like_post_actions.first

    assert_equal 1, @post.like_by_user_actions.length
    assert_kind_of Action, @post.like_by_user_actions.first
  end

  test "@user.has_many :like_posts / @post.has_many :like_users" do
    action = @user.like_post(@post)
    assert_not_equal false, action

    assert_equal 1, @user.like_posts.length
    assert_kind_of Post, @user.like_posts.first

    assert_equal 1, @post.like_by_users.length
    assert_kind_of User, @post.like_by_users.first
  end
end