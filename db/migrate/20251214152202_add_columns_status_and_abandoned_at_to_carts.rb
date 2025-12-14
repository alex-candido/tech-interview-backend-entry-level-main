# frozen_string_literal: true

class AddColumnsStatusAndAbandonedAtToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :integer, null: false, default: 0
    add_column :carts, :abandoned_at, :datetime

    change_column :carts, :total_price, :decimal, precision: 10, scale: 2, null: false, default: 0.0
  end
end
