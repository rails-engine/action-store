## ActionStore

[![Gem Version](https://badge.fury.io/rb/action-store.svg)](https://badge.fury.io/rb/action-store) [![build](https://github.com/rails-engine/action-store/workflows/build/badge.svg)](https://github.com/rails-engine/action-store/actions?query=workflow%3Abuild)

Store different kinds of actions (Like, Follow, Star, Block, etc.) in a single table via ActiveRecord Polymorphic Associations.

- Like Posts/Comment/Reply ...
- Watch/Subscribe to Posts
- Follow Users
- Favorite Posts
- Read Notifications/Messages

And more and more.

[中文介绍和使用说明](https://ruby-china.org/topics/32262)

## Basic table struct

| Column                     | Chars Limit | Description                                                                 |
| -------------------------- | ----------- | --------------------------------------------------------------------------- |
| `action_type`              | 64          | The type of action [like, watch, follow, star, favorite]                    |
| `action_option`            | 64          | Secondary option for storing your custom status, or null if unneeded.       |
| `target_type`, `target_id` | 64          | Polymorphic Association for different `Target` models [User, Post, Comment] |
| `user_type`                | 64          | Polymorphic Association for different user model [User, Group, Member]      |

### Uniqueness

> version: ">= 0.4.0"

The have database unique index on fields: `[action_type, target_type, target_id, user_type, user_id]` for keep uniqueness for same action from user to target.

## Usage

```rb
gem 'action-store'
```

and run `bundle install`

Generate Migrations:

```bash
$ rails g action_store:install
create  config/initializers/action_store.rb
migration 20170208024704_create_actions.rb from action_store
```

and run `rails db:migrate`.

### Define Actions

Use `action_store` to define actions:

```rb
# app/models/user.rb
class User < ActiveRecord::Base
  action_store <action_type>, <target>, opts
end
```

#### Convention Over Configuration:

| action, target                                                                                         | Target Model  | Target `counter_cache_field` | User `counter_cache_field` | Target has_many                                                 | User has_many                                             |
| ------------------------------------------------------------------------------------------------------ | ------------- | ---------------------------- | -------------------------- | --------------------------------------------------------------- | --------------------------------------------------------- |
| `action_store :like, :post`                                                                            | `Post`        |                              |                            | `has_many :like_by_user_actions`, `has_many :like_by_users`     | `has_many :like_post_actions`, `has_many :like_posts`     |
| `action_store :like, :post, counter_cache: true`                                                       | `Post`        | `likes_count`                |                            | `has_many :like_by_user_actions`, `has_many :like_by_users`     | `has_many :like_post_actions`, `has_many :like_posts`     |
| `action_store :star, :project, class_name: 'Repository'`                                               | `Repository ` | `stars_count`                | `star_projects_count`      | `has_many :star_by_user_actions`, `has_many :star_by_users`     |
| `action_store :follow, :user`                                                                          | `User`        | `follows_count`              | `follow_users_count`       | `has_many :follow_by_user_actions`, `has_many :follow_by_users` | `has_many :follow_user_actions`, `has_many :follow_users` |
| `action_store :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'` | `User`        | `followers_count `           | `following_count `         | `has_many :follow_by_user_actions`, `has_many :follow_by_users` | `has_many :follow_user_actions`, `has_many :follow_users` |

for example:

```rb
# app/models/user.rb
class User < ActiveRecord::Base
  action_store :like, :post, counter_cache: true
  action_store :star, :post, counter_cache: true, user_counter_cache: true
  action_store :follow, :post
  action_store :like, :comment, counter_cache: true
  action_store :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'
end
```

### Counter Cache

Add counter_cache field to target and user tables.

```rb
add_column :users, :star_posts_count, :integer, default: 0
add_column :users, :followers_count, :integer, default: 0
add_column :users, :following_count, :integer, default: 0

add_column :posts, :likes_count, :integer, default: 0
add_column :posts, :stars_count, :integer, default: 0

add_column :comments, :likes_count, :integer, default: 0
```

#### Example usage:

@user likes @post

```rb
irb> User.create_action(:like, target: @post, user: @user)
true
irb> @user.create_action(:like, target: @post)
true
irb> @post.reload.likes_count
1
```

@user1 unlikes @user2

```rb
irb> User.destroy_action(:follow, target: @post, user: @user)
true
irb> @user.destroy_action(:like, target: @post)
true
irb> @post.reload.likes_count
0
```

Check if @user1 likes @post

```rb
irb> action = User.find_action(:follow, target: @post, user: @user)
irb> action = @user.find_action(:like, target: @post)
irb> action.present?
true
```

**Other following use cases:**

```rb
# @user1 -> follow @user2
irb> @user1.create_action(:follow, target: @user2)
irb> @user1.reload.following_count
=> 1
irb> @user2.reload.followers_count
=> 1
irb> @user1.follow_user?(@user2)
=> true

# @user2 -> follow @user1
irb> @user2.create_action(:follow, target: @user1)
irb> @user2.follow_user?(@user1)
=> true

# @user1 -> follow @user3
irb> @user1.create_action(:follow, target: @user3)

# @user1 -> unfollow @user3
irb> @user1.destroy_action(:follow, target: @user3)
```

**Subscribe cases:**

Sometimes, you may need use `action_option` option.

For example, user to subscribe a issue (like GitHub Issue) on issue create, and they wants keep in subscribe list on unsubscribe for makesure next comment will not subscribe this issue again.

So, in this case, we should not use `@user.unsubscribe_issue` method to destroy action record, we need set a value on `action_option` to mark this subscribe is `ignore`.

```rb
irb> User.create_action(:subscribe, target: @issue, user: @user)
irb> @user.subscribe_issue?(@issue)
=> true

irb> User.create_action(:subscribe, target: @issue, user: @user, action_option: "ignore")
irb> @user.subscribe_issue?(@issue)
=> true

irb> action = User.find_action(:subscribe, target: @issue, user: @user)
irb> action.action_option
=> "ignore"

irb> @issue.subscribe_by_user_actions.count
=> 1
irb> @issue.subscribe_by_user_actions.where(action_option: nil).count
=> 0
```

## Use different tables for store actions.

> since 1.1.0

Sometimes, you may want to store actions into different table, for example, **Like** scenarios often have a lot of data, we wants store them into `likes` table.

Create a migration and model

```bash
$ rails g migration create_likes
```

And then modify this migration file to let this table have same struct like the `actions`

```rb
class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.string :action_type, null: false
      t.string :action_option
      t.string :target_type
      t.bigint :target_id
      t.string :user_type
      t.bigint :user_id

      t.timestamps
    end

    add_index :likes, %i[user_type user_id action_type]
    add_index :likes, %i[target_type target_id action_type]
    add_index :likes, %i[action_type target_type target_id user_type user_id], unique: true, name: :uk_likes_target_user
  end
end
```

Create a `app/model/like.rb` model file:

```rb
class Like < Action
  self.table_name = "likes"
end
```

And then change you `action_store` define to special some case to use Like model:

```rb
# app/models/user.rb
class User < ActiveRecord::Base
  action_store :like, :post, counter_cache: true, action_class_name: "Like"
  action_store :like, :comment, counter_cache: true, action_class_name: "Like"
end
```

Now, `user.like_post`, `user.like_comment` will store the actions into `likes` table.

## Built-in relations and methods

When you call `action_store`, ActionStore will define many-to-many relations for User and Target models.

For example:

```rb
class User < ActiveRecord::Base
  action_store :like, :post
  action_store :block, :user
end
```

Defines many-to-many relations:

- For User model: `<action>_<target>s` (like_posts)
- For Target model: `<action>_by_users` (like_by_users)

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

And `User` model will now have methods:

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
