class CreateUserActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :user_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :activity_type, null: false
      t.string :title, null: false
      t.text :description
      t.string :icon, null: false
      t.string :color, null: false
      t.references :reference, polymorphic: true

      t.timestamps
    end

    add_index :user_activities, [ :user_id, :activity_type ]
    add_index :user_activities, [ :user_id, :created_at ]
    add_index :user_activities, [ :reference_type, :reference_id ]
  end
end
