class CreateBlogPerson < ActiveRecord::Migration[5.0]
  def change
    create_table :blog_people do |t|
      t.string :name
    end
  end
end
