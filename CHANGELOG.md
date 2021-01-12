## 1.1.0

- Allows to configure different Models / Tables for store actions. (#16)

```rb
# app/models/like.rb
class Like < Action
  self.table_name = "likes"
end
```

```rb
# app/models/user.rb
class User < ActiveRecord::Base
  action_store :like, :post, counter_cache: true, action_class_name: "Like"
  action_store :like, :comment, counter_cache: true, action_class_name: "Like"
end
```

## 1.0.0

- Require Rails >= 5.2.
- Fix primary key for use `bigint` column type.

  0.4.3

---

- Auto reload `target`, when action/unaction target.

```rb
irb> post.likes_count
=> 0
irb> user.like_post(post)
irb> post.likes_count
=> 1
irb> user.unlike_post(post)
irb> post.likes_count
=> 0
```

## 0.4.2

- Add `UNIQUE INDEX` on `:action_type, :target_type, :target_id, :user_type, :user_id` for makesure action uniqueness.
  > NOTE! If you already have actions in database, the new migration may have issue on `db:migrate`,
  > so you need fix them by remove duplicate.
- Now `create_action` method use database to makesure unique.

**Upgrade from 0.3.x:**

You must use `rails g action_store:install` to generate the new migration file.

```bash
$ rails g action_store:install
    conflict  config/initializers/action_store.rb
Overwrite config/initializers/action_store.rb? (enter "h" for help) [Ynaqdhm] n
        skip  config/initializers/action_store.rb
Copied migration 20181121061544_add_unique_index_to_actions.action_store.rb from action_store
```

## 0.3.3

- Fix for supports Rails 5.2;

  0.3.2

---

- Gem dependency for Rails 5.x.

  0.3.1

---

- Fix that `:user_counter_cache` was incorrect, it not count with target_type.

  0.3.0

---

- Fix for action_store in Model that not named `User`.
- Fix has_many name when `User` model in a namespace.

For example:

```rb
class Person
  action_store :like, :post
end

module Blog
  class User
    action_store :like, :post
  end
end

@post.like_by_people, @post.like_by_person_actions
@blog_user.like_post(@post), @post.like_by_blog_users, @post.like_by_blog_user_actions
```

## 0.2.2

- Fix #2 support Target that under a namespace.

```rb
action_store :like, :blog_post, class_name: 'Blog::Post'
```

## 0.2.1

- Use `ActiveSupport.on_load` to hook into Active Record.

  0.2.0

---

- New API, define action in User model.
- Builtin Many-to-Many relations and methods.

  0.1.0

---

- First release.
