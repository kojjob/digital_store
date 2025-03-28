class CreateActionItems < ActiveRecord::Migration[7.0]
  def change
    create_table :action_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :priority, default: 1  # medium priority by default
      t.date :due_date
      t.boolean :completed, default: false

      t.timestamps
    end

    add_index :action_items, [ :user_id, :completed ]
    add_index :action_items, [ :user_id, :priority ]
    add_index :action_items, [ :user_id, :due_date ]
  end
end
