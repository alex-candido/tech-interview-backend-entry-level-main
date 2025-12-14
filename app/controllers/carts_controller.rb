# frozen_string_literal: true

class CartsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  before_action :set_product, only: %i[create update_item]

  # GET /cart
  def show
    render json: cart_payload(current_cart), status: :ok
  end

  # POST /cart
  def create
    cart_item = current_cart.add_item(product: @product, quantity: cart_params[:quantity])

    if cart_item.persisted?
      render json: cart_payload(current_cart), status: :created
    else
      render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /cart/add_item
  def update_item
    cart_item = current_cart.update_item_quantity(product: @product, quantity: cart_params[:quantity])

    if cart_item.nil?
      render json: { error: "Product not found in cart" }, status: :not_found
    elsif cart_item.save
      render json: cart_payload(current_cart), status: :ok
    else
      render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
    end
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

  def set_product
    @product = Product.find(cart_params[:product_id])
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
