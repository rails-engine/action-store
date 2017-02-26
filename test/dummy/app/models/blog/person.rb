module Blog
  class Person < ActiveRecord::Base
    self.table_name = 'blog_people'
    action_store :like, :post, counter_cache: true
  end
end
