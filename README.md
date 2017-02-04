ActionStore
-----------

[![Gem Version](https://badge.fury.io/rb/activestore.svg)](https://badge.fury.io/rb/activestore) [![Build Status](https://travis-ci.org/rails-engine/activestore.svg)](https://travis-ci.org/rails-engine/activestore) [![Code Climate](https://codeclimate.com/github/rails-engine/activestore/badges/gpa.svg)](https://codeclimate.com/github/rails-engine/activestore) [![codecov.io](https://codecov.io/github/rails-engine/activestore/coverage.svg?branch=master)](https://codecov.io/github/rails-engine/activestore?branch=master) [![](http://inch-ci.org/github/rails-engine/activestore.svg?branch=master)](http://inch-ci.org/github/rails-engine/activestore?branch=master)

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

  allow_actions %w(like follow star)
end
```