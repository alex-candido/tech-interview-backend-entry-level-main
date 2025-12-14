# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe "routing" do
    it "routes GET /cart to #show" do
      expect(get: "/cart").to route_to("carts#show")
    end

    it "routes POST /cart to #create" do
      expect(post: "/cart").to route_to("carts#create")
    end

    it "routes POST /cart/add_item to #update_item" do
      expect(post: "/cart/add_item").to route_to("carts#update_item")
    end

    it "routes DELETE /cart/:product_id to #remove_item" do
      expect(delete: "/cart/1").to route_to("carts#remove_item", product_id: "1")
    end
  end
end
