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
