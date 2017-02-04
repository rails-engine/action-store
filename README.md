ActionStore
-----------

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

TODO