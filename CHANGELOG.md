0.3.2
-----

- Gem dependency for Rails 5.x.

0.3.1
-----

- Fix that `:user_counter_cache` was incorrect, it not count with target_type.

0.3.0
-----

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

0.2.2
-----

- Fix #2 support Target that under a namespace.

```rb
action_store :like, :blog_post, class_name: 'Blog::Post'
```

0.2.1
-----

- Use `ActiveSupport.on_load` to hook into Active Record.

0.2.0
-----

- New API, define action in User model.
- Builtin Many-to-Many relations and methods.

0.1.0
-----

- First release.
