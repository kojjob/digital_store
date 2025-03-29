# frozen_string_literal: true

class CreatePaymentAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :payment_processor, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_id
      t.text :metadata
      t.inet :ip_address
      t.string :user_agent
      
      t.timestamps

      # Add index for faster lookup by event type and payment processor
      t.index [:event_type, :payment_processor]
    end
  end
end
