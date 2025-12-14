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
require "rails_helper"

RSpec.describe CartItem, type: :model do
  context "when validating quantity" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }

    it "is valid with a quantity greater than 0" do
      cart_item = build(:cart_item, cart: cart, product: product, quantity: 1)
      expect(cart_item).to be_valid
    end

    it "is invalid with quantity 0" do
      cart_item = build(:cart_item, cart: cart, product: product, quantity: 0)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end

    it "is invalid with negative quantity" do
      cart_item = build(:cart_item, cart: cart, product: product, quantity: -1)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end
  end

  describe "#total_price" do
    let(:product) { create(:product, unit_price: 10.0) }
    let(:cart_item) { build(:cart_item, product: product, quantity: 3) }

    it "calculates the total price correctly" do
      expect(cart_item.total_price).to eq(30.0) # 3 * 10.0
    end
  end

  describe "callbacks" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, unit_price: 10.0) }

    before do
      cart.update_column(:total_price, 0.0)
    end

    context "after_save" do
      it "triggers recalculate_total! on the associated cart when creating an item" do
        expect(cart).to receive(:recalculate_total!).once
        create(:cart_item, cart: cart, product: product, quantity: 1)
      end

      it "triggers recalculate_total! on the associated cart when updating an item" do
        cart_item = create(:cart_item, cart: cart, product: product, quantity: 1)
        expect(cart).to receive(:recalculate_total!).once
        cart_item.update(quantity: 2)
      end
    end

    context "after_destroy" do
      it "triggers recalculate_total! on the associated cart when destroying an item" do
        cart_item = create(:cart_item, cart: cart, product: product, quantity: 1)
        expect(cart).to receive(:recalculate_total!).once
        cart_item.destroy
      end
    end
  end
end
