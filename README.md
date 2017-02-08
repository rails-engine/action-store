ActionStore
-----------

[![Gem Version](https://badge.fury.io/rb/action-store.svg)](https://badge.fury.io/rb/action-store) [![Build Status](https://travis-ci.org/rails-engine/action-store.svg)](https://travis-ci.org/rails-engine/action-store) [![Code Climate](https://codeclimate.com/github/rails-engine/action-store/badges/gpa.svg)](https://codeclimate.com/github/rails-engine/action-store) [![codecov.io](https://codecov.io/github/rails-engine/action-store/coverage.svg?branch=master)](https://codecov.io/github/rails-engine/action-store?branch=master) [![](http://inch-ci.org/github/rails-engine/action-store.svg?branch=master)](http://inch-ci.org/github/rails-engine/action-store?branch=master)

Store different kind of actions (Like, Follow, Star, Block ...) in one table via ActiveRecord Polymorphic Association.

- Like Post/Comment/Reply ...
- Watch/Subscribe Post
- Follow User
- Favorite Post
- Read Notification/Message

And more and more.

[中文介绍和使用说明](https://ruby-china.org/topics/32262)

## Basic table struct

| Field | Means |
| ----- | ----- |
| `action_type` | The type of action [like, watch, follow, star, favorite] |
| `action_option` | Secondly option for store you custom status, or you can let it null if you don't needs it. |
| `target_type`, `target_id` | Polymorphic Association for difference `Target` models [User, Post, Comment] |

## Usage

```rb
gem 'action-store'
```

and run `bundle install`

Generate Migrations:

```
$ rails g action_store:install
create  config/initializers/action_store.rb
migration 20170208024704_create_actions.rb from action_store
```

and run `rails db:migrate`.

### Define Actions

You can use `action_store` to define actions:

app/models/user.rb

```
class User < ActiveRecord::Base
  action_store <action_type>, <target>, opts
end
```

#### Convention Over Configuration:

| action, target | Target Model | Target `counter_cache_field` | User `counter_cache_field` | Target has_many | User has_many |
| ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| `action_store :like, :post` | `Post` | | | `has_many :like_by_user_actions`, `has_many :like_by_users` | `has_many :like_post_actions`, `has_many :like_posts` |
| `action_store :like, :post, counter_cache: true` | `Post` | `likes_count` |  | `has_many :like_by_user_actions`, `has_many :like_by_users` | `has_many :like_post_actions`, `has_many :like_posts` |
| `action_store :star, :project, class_name: 'Repository'` | `Repository ` | `stars_count` | `star_projects_count` | `has_many :star_by_user_actions`, `has_many :star_by_users` |
| `action_store :follow, :user` | `User` | `follows_count` | `follow_users_count` | `has_many :follow_by_user_actions`, `has_many :follow_by_users` | `has_many :follow_user_actions`, `has_many :follow_users` |
| `action_store :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'` | `User` | `followers_count ` | `following_count ` | `has_many :follow_by_user_actions`, `has_many :follow_by_users` | `has_many :follow_user_actions`, `has_many :follow_users` |

for example:

```rb
# app/models/action.rb
class User < ActiveRecord::Base
  action_store :like, :post, counter_cache: true
  action_store :star, :post, counter_cache: true, user_counter_cache: true
  action_store :follow, :post
  action_store :like, :comment, counter_cache: true
  action_store :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'
end
```

### Counter Cache

And you need add counter_cache field to target, user table.

```rb
add_column :users, :star_posts_count, :integer, default: 0
add_column :users, :followers_count, :integer, default: 0
add_column :users, :following_count, :integer, default: 0

add_column :posts, :likes_count, :integer, default: 0
add_column :posts, :stars_count, :integer, default: 0

add_column :comments, :likes_count, :integer, default: 0
```

#### Now you can use like this:

@user -> like @post

```rb
irb> User.create_action(:like, target: @post, user: @user)
true
irb> @user.create_action(:like, target: @post)
true
irb> @post.reload.likes_count
1
```

@user1 -> unlike @user2

```rb
irb> User.destroy_action(:follow, target: @post, user: @user)
true
irb> @user.destroy_action(:like, target: @post)
true
irb> @post.reload.likes_count
0
```

Check @user1 is liked @post

```rb
irb> action = User.find_action(:follow, target: @post, user: @user)
irb> action = @user.find_action(:like, target: @post)
irb> action.present?
true
```

User follow cases:

```rb
# @user1 -> follow @user2
@user1.create_action(:follow, target: @user2)
@user1.reload.following_count => 1
@user2.reload.followers_count_ => 1
@user1.follow_user?(@user2) => true
# @user2 -> follow @user1
@user2.create_action(:follow, target: @user1)
@user2.follow_user?(@user1) => true
# @user1 -> follow @user3
@user1.create_action(:follow, target: @user3)
# @user1 -> unfollow @user3
 @user1.destroy_action(:follow, target: @user3)
```

## Builtin relations and methods

When you called `action_store`, ActionStore will define Many-to-Many relations for User and Target model.

for example:

```rb
class User < ActiveRecord::Base
  action_store :like, :post
  action_store :block, :user
end
```

It will defines Many-to-Many relations:

- For User model will defined: `<action>_<target>s` (like_posts)
- For Target model will defined: `<action>_by_users` (like_by_users)

```rb
# for User model
has_many :like_post_actions
has_many :like_posts, through: :like_post_actions
## as user
has_many :block_user_actions
has_many :block_users, through: :block_user_actions
## as target
has_many :block_by_user_actions
has_many :block_by_users, through: :block_by_user_actions

# for Target model
has_many :like_by_user_actions
has_many :like_by_users, through: :like_user_actions
```

And `User` model will have methods:

- @user.create_action(:like, target: @post)
- @user.destroy_action(:like, target: @post)
- @user.find_action(:like, target: @post)
- @user.like_post(@post)
- @user.like_post?(@post)
- @user.unlike_post(@post)
- @user.block_user(@user1)
- @user.unblock_user(@user1)
- @user.like_post_ids
- @user.block_user_ids
- @user.block_by_user_ids
