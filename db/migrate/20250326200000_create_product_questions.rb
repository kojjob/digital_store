class CreateProductQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :product_questions do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :asked_by, null: false
      t.text :question, null: false
      t.text :answer
      t.string :answered_by
      t.datetime :answered_at

      t.timestamps
    end

    add_index :product_questions, [ :product_id, :created_at ]
  end
end
