class AddPublishedToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :published, :boolean, default: true
    add_index :reviews, :published
  end
end
