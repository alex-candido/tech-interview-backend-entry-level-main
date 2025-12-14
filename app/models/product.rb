# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  unit_price :decimal(10, 2)   not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Product < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  validates_presence_of :name, :unit_price
  validates_numericality_of :unit_price, greater_than_or_equal_to: 0
end
