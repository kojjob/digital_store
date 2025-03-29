class AddPaymentAndTrackingFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    # Only add fields that don't already exist
    add_column :orders, :payment_details, :text unless column_exists?(:orders, :payment_details)
    add_column :orders, :notes, :text unless column_exists?(:orders, :notes)

    # Add index if it doesn't exist
    unless index_exists?(:orders, :payment_id)
      add_index :orders, :payment_id
    end
  end
end
