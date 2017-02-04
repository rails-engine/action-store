class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table(:users) do |t|
      t.string :name
      t.integer :followers_count
      t.integer :following_count

      t.timestamps null: false
    end

    create_table(:posts) do |t|
      t.string :title
      t.integer :user_id
      t.integer :likes_count
      t.integer :stars_count

      t.timestamps null: false
    end

    create_table(:comments) do |t|
      t.integer :post_id
      t.integer :user_id
      t.string :body
      t.integer :likes_count

      t.timestamps null: false
    end
  end
end
