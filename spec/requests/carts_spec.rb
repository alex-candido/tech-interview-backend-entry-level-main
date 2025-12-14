# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/cart", type: :request do
  let!(:product) { create(:product, unit_price: 10.0) }

  describe "POST /cart" do
    context "when adding a product to a new cart" do
      let(:valid_params) { { product_id: product.id, quantity: 2 } }

      it "creates a new Cart and a new CartItem" do
        expect {
          post cart_url, params: valid_params, as: :json
        }.to change(Cart, :count).by(1).and change(CartItem, :count).by(1)
      end

      it "returns a successful :created status and correct data" do
        post cart_url, params: valid_params, as: :json
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["total_price"]).to eq("20.0")
      end
    end

    context "when the product is already in the cart" do
      let!(:cart) { create(:cart) }
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      before do
        allow_any_instance_of(CartsController).to receive(:current_cart).and_return(cart)
      end

      it "increments the quantity of the existing item" do
        post cart_url, params: { product_id: product.id, quantity: 2 }, as: :json
        expect(cart_item.reload.quantity).to eq(3) # 1 + 2 = 3
      end
    end
  end

  describe "GET /cart" do
    context "when cart has items" do
      let!(:cart) { create(:cart) }
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

      before do
        allow_any_instance_of(CartsController).to receive(:current_cart).and_return(cart)
        get cart_url, as: :json
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the cart with its items" do
        json_response = JSON.parse(response.body)
        expect(json_response["products"].size).to eq(1)
        expect(json_response["products"].first["id"]).to eq(product.id)
      end
    end

    context "when cart is empty" do
      it "returns an empty cart" do
        get cart_url, as: :json
        json_response = JSON.parse(response.body)
        expect(json_response["products"]).to be_empty
        expect(json_response["total_price"]).to eq("0.0")
      end
    end
  end

  describe "POST /cart/add_item" do
    let!(:cart) { create(:cart) }
    let!(:product) { create(:product) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    before do
      allow_any_instance_of(CartsController).to receive(:current_cart).and_return(cart)
    end

    context "with valid parameters" do
      it "returns a successful :ok status" do
        post add_item_cart_path, params: { product_id: product.id, quantity: 5 }, as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context "with an invalid product_id" do
      it "returns a :not_found status" do
        post add_item_cart_path, params: { product_id: -999, quantity: 5 }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an invalid quantity" do
      it "returns an :unprocessable_entity status" do
        post add_item_cart_path, params: { product_id: product.id, quantity: 0 }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:cart) { create(:cart) }
    let!(:product) { create(:product) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

    before do
      allow_any_instance_of(CartsController).to receive(:current_cart).and_return(cart)
    end

    context "when removing an existing item" do
      it "destroys the cart item" do
        expect {
          delete "/cart/#{product.id}", as: :json
        }.to change(CartItem, :count).by(-1)
      end

      it "returns a successful :ok status" do
        delete "/cart/#{product.id}", as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context "when trying to remove a non-existent item" do
      it "returns a :not_found status" do
        delete cart_path(-999), as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
