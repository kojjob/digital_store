# frozen_string_literal: true

class AddIsDigitalToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :is_digital, :boolean, default: false
    add_index :products, :is_digital
  end
end
