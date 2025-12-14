# frozen_string_literal: true

# == Schema Information
#
# Table name: cart_items
#
#  id         :bigint           not null, primary key
#  cart_id    :bigint           not null
#  product_id :bigint           not null
#  quantity   :integer          default(1), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CartItem < ApplicationRecord
  after_save :recalculate_cart_total
  after_destroy :recalculate_cart_total

  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  def total_price
    product.unit_price * quantity
  end

  private
    def recalculate_cart_total
      cart.recalculate_total! if cart.present?
    end
end
