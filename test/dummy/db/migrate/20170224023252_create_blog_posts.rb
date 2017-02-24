class CreateBlogPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.integer :likes_count
      t.timestamps null: false
    end
  end
end
