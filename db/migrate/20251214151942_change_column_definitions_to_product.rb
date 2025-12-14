# frozen_string_literal: true

class ChangeColumnDefinitionsToProduct < ActiveRecord::Migration[7.1]
  def change
    rename_column :products, :price, :unit_price

    change_column :products, :unit_price, :decimal, precision: 10, scale: 2, null: false
    change_column :products, :name, :string, null: false
  end
end
