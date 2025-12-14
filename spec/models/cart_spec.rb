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
require "rails_helper"

RSpec.describe Cart, type: :model do
  context "when validating" do
    it "validates numericality of total_price" do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe ".mark_as_abandoned" do
    it "marks active carts as abandoned if inactive for 3 hours" do
      cart = create(:cart, status: :active, updated_at: 4.hours.ago)

      expect {
        Cart.mark_as_abandoned
      }.to change { cart.reload.status }.from("active").to("abandoned")
       .and change { cart.reload.abandoned_at }.to be_present
    end

    it "does not mark active carts as abandoned if inactive for less than 3 hours" do
      cart = create(:cart, status: :active, updated_at: 2.hours.ago)

      Cart.mark_as_abandoned

      cart.reload
      expect(cart.status).to eq("active")
      expect(cart.abandoned_at).to be_nil
    end
  end

  describe ".purge_old_abandoned" do
    it "removes abandoned carts if abandoned for more than 7 days" do
      create(:cart, status: :abandoned, abandoned_at: 8.days.ago)

      expect {
        Cart.purge_old_abandoned
      }.to change(Cart, :count).by(-1)
    end

    it "does not remove abandoned carts if abandoned for less than 7 days" do
      create(:cart, status: :abandoned, abandoned_at: 6.days.ago)

      expect {
        Cart.purge_old_abandoned
      }.not_to change(Cart, :count)
    end
  end

  describe "instance methods" do
    let(:cart) { create(:cart) }
    let(:product1) { create(:product, unit_price: 10.0) }
    let(:product2) { create(:product, unit_price: 5.0) }

    describe "#add_item" do
      it "adds a new item to the cart" do
        cart.add_item(product: product1, quantity: 2)
        expect(cart.cart_items.count).to eq(1)
        expect(cart.cart_items.first.quantity).to eq(2)
      end

      it "increments the quantity of an existing item" do
        cart.add_item(product: product1, quantity: 1)
        cart.add_item(product: product1, quantity: 2)
        expect(cart.cart_items.count).to eq(1)
        expect(cart.cart_items.first.quantity).to eq(3)
      end

      it "updates the cart total price via callback" do
        cart.add_item(product: product1, quantity: 2)
        expect(cart.reload.total_price).to eq(20.0)
      end
    end

    describe "#update_item_quantity" do
      it "sets the absolute quantity of an item" do
        cart.add_item(product: product1, quantity: 1)
        # O método agora apenas prepara o objeto, o teste precisa salvá-lo.
        cart_item = cart.update_item_quantity(product: product1, quantity: 5)
        cart_item.save
        expect(cart.cart_items.first.reload.quantity).to eq(5)
      end

      it "updates the cart total price via callback" do
        cart.add_item(product: product1, quantity: 1)
        # O método agora apenas prepara o objeto, o teste precisa salvá-lo para acionar o callback.
        cart_item = cart.update_item_quantity(product: product1, quantity: 5)
        cart_item.save
        expect(cart.reload.total_price).to eq(50.0)
      end
    end

    describe "#remove_item" do
      before do
        cart.add_item(product: product1, quantity: 2)
        cart.add_item(product: product2, quantity: 1)
      end

      it "removes an item from the cart" do
        expect {
          cart.remove_item(product_id: product1.id)
        }.to change(cart.cart_items, :count).by(-1)
      end

      it "updates the cart total price via callback" do
        cart.remove_item(product_id: product1.id)
        expect(cart.reload.total_price).to eq(5.0)
      end
    end
  end
end
