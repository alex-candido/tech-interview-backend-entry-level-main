# frozen_string_literal: true

# == Schema Information
#
# Table name: carts
#
#  id           :bigint           not null, primary key
#  total_price  :decimal(10, 2)   default(0.0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  status       :integer          default("active"), not null
#  abandoned_at :datetime
#
class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  enum status: { active: 0, inactive: 1, abandoned: 2 }

  def add_item(product:, quantity: 1)
    cart_item = cart_items.find_by(product: product)

    if cart_item
      cart_item.quantity += quantity.to_i
    else
      cart_item = cart_items.build(product: product, quantity: quantity.to_i)
    end

    cart_item.save
    cart_item
  end

  def update_item_quantity(product:, quantity: 1)
    cart_item = cart_items.find_or_initialize_by(product: product)
    cart_item.quantity = quantity.to_i

    cart_item.save
    cart_item
  end

  def recalculate_total!
    new_total = cart_items.joins(:product).sum("cart_items.quantity * products.unit_price")
    update(total_price: new_total)
  end

  def remove_item(product_id:)
    cart_item = cart_items.find_by(product_id: product_id)
    return false unless cart_item

    cart_item.destroy
  end
end
