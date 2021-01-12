class CreateFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :follows do |t|
      t.string :action_type, null: false
      t.string :action_option
      t.string :target_type
      t.bigint :target_id
      t.string :user_type
      t.bigint :user_id

      t.timestamps
    end

    add_index :follows, %i[user_type user_id action_type]
    add_index :follows, %i[target_type target_id action_type]
    add_index :follows, %i[action_type target_type target_id user_type user_id], unique: true, name: :uk_follows_target_user
  end
end
