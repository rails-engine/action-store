class CreateActions < ActiveRecord::Migration[5.0]
  def change
    create_table :actions do |t|
      t.string :action_type, null: false
      t.string :action_option
      t.string :target_type
      t.string :target_id
      t.integer :user_id

      t.timestamps
    end

    add_index :actions, [:user_id, :action_type]
  end
end
