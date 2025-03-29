class AddSuperAdminToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :super_admin, :boolean, default: false

    # Index for faster queries
    add_index :users, :super_admin
  end
end
