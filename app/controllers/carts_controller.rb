# frozen_string_literal: true

class CartsController < ApplicationController
  # GET /cart
  def show
    render json: cart_payload(current_cart), status: :ok
  end

  # POST /cart
  def create
    product = Product.find_by(id: cart_params[:product_id])
    if product.nil?
      return render json: { error: "Product not found" }, status: :not_found
    end

    cart_item = current_cart.add_item(product: product, quantity: cart_params[:quantity])

    if cart_item.errors.blank?
      render json: cart_payload(current_cart), status: :created
    else
      render json: cart_item.errors, status: :unprocessable_entity
    end
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  # POST /cart/add_item
  def update_item
    product = Product.find_by(id: cart_params[:product_id])
    if product.nil?
      return render json: { error: "Product not found" }, status: :not_found
    end

    cart_item = current_cart.update_item_quantity(product: product, quantity: cart_params[:quantity])

    if cart_item.errors.blank?
      render json: cart_payload(current_cart), status: :ok
    else
      render json: cart_item.errors, status: :unprocessable_entity
    end
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  end

  # DELETE /cart/:product_id
  def remove_item
    if current_cart.remove_item(product_id: params[:product_id])
      render json: cart_payload(current_cart), status: :ok
    else
      render json: { error: "Product not found in cart" }, status: :not_found
    end
  end

  private
    def cart_params
      params.permit(:product_id, :quantity)
    end

    def cart_payload(cart)
      {
        id: cart.id,
        products: cart.cart_items.includes(:product).map do |item|
          {
            id: item.product.id,
            name: item.product.name,
            quantity: item.quantity,
            unit_price: item.product.unit_price,
            total_price: item.total_price
          }
        end,
        total_price: cart.total_price
      }
    end
end
