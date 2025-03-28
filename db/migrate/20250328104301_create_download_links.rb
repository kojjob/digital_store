class CreateDownloadLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :download_links do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :order, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.integer :download_count, default: 0, null: false
      t.integer :download_limit, default: 5, null: false
      t.boolean :active, default: true, null: false
      t.string :file_path
      t.string :file_name
      t.string :file_size
      t.string :content_type

      t.timestamps
    end

    add_index :download_links, :token, unique: true
  end
end
