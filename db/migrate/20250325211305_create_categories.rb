class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.references :parent, null: true, foreign_key: { to_table: :categories }
      t.integer :position
      t.boolean :visible

      t.timestamps
    end
    add_index :categories, :slug, unique: true
  end
end
