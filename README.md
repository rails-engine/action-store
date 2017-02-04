ActionStore
-----------

[![Gem Version](https://badge.fury.io/rb/actionstore.svg)](https://badge.fury.io/rb/actionstore) [![Build Status](https://travis-ci.org/rails-engine/actionstore.svg)](https://travis-ci.org/rails-engine/actionstore) [![Code Climate](https://codeclimate.com/github/rails-engine/actionstore/badges/gpa.svg)](https://codeclimate.com/github/rails-engine/actionstore) [![codecov.io](https://codecov.io/github/rails-engine/actionstore/coverage.svg?branch=master)](https://codecov.io/github/rails-engine/actionstore?branch=master) [![](http://inch-ci.org/github/rails-engine/actionstore.svg?branch=master)](http://inch-ci.org/github/rails-engine/actionstore?branch=master)

Store difference kind of actions (Like, Follow, Star, Block ...) in one table via ActiveRecord Polymorphic Association.

- Like Post/Comment/Reply ...
- Watch Post
- Follow User
- Favorite Post

And more and more.

### Basic table struct

| Field | Means |
| ----- | ----- |
| action_type | The type of action [like, watch, follow, star, favorite] |
| action_option | Secondly option for store you custom status, or you can let it null if you don't needs it. |
| target_type, target_id | Polymorphic Association for difference models [User, Post, Comment] |

### Usage

```rb
class Action < ActiveRecord::Base
  include ActionStore::Model

  action_for :like, :post, counter_cache: true
  action_for :star, :post, counter_cache: true
  action_for :follow, :post
  action_for :like, :comment, counter_cache: true
  action_for :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'
end
```

#### Now you can use like this:

@user -> like @post

```rb
irb> Action.create_action(:like, target: @post, user: @user)
irb> @post.reload.likes_count
1
```

@user1 -> unlike @user2

```rb
irb> Action.destroy_action(:follow, target: @post, user: @user)
irb> @post.reload.likes_count
0
```

Check @user1 is liked @post

```rb
irb> action = Action.find_action(:follow, target: @post, user: @user)
irb> action.present?
true
```

User follow cases:

```rb
# @user1 -> follow @user2
Action.create_action(:follow, target: @user2, user: @user1)
@user1.reload.following_count => 1
@user2.reload.followers_count_ => 1
# @user2 -> follow @user1
Action.create_action(:follow, target: @user1, user: @user2)
# @user1 -> follow @user3
Action.create_action(:follow, target: @user3, user: @user1)
# @user1 -> unfollow @user3
Action.destroy_action(:follow, target: @user3, user: @user1)
```