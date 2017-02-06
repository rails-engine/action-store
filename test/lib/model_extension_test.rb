require 'test_helper'

class ActionStore::ModelExtentionTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @user1 = create(:user)
    @post = create(:post)
    @post1 = create(:post)
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
    assert_kind_of Monkey, @user.like_post_actions.first

    assert_equal 1, @post.like_by_user_actions.length
    assert_kind_of Monkey, @post.like_by_user_actions.first
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