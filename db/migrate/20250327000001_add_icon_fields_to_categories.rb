class AddIconFieldsToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :icon_name, :string
    add_column :categories, :icon_color, :string, default: "blue"
  end
end
