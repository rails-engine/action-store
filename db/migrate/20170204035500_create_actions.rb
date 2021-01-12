# frozen_string_literal: true

class CreateActions < ActiveRecord::Migration[5.2]
  def change
    create_table :actions do |t|
      t.string :action_type, null: false
      t.string :action_option
      t.string :target_type
      t.bigint :target_id
      t.string :user_type
      t.bigint :user_id

      t.timestamps
    end

    add_index :actions, %i[user_type user_id action_type]
    add_index :actions, %i[target_type target_id action_type]
  end
end
