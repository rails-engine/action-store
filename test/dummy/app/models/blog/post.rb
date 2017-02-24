module Blog
  class Post < ActiveRecord::Base
    belongs_to :user
  end
end
