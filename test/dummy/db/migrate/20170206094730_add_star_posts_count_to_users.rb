class AddStarPostsCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :star_posts_count, :integer
  end
end
