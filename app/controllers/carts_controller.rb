class CartsController < ApplicationController
  # GET /cart
  def show
    render json: cart_payload(current_cart), status: :ok
  end

  # POST /cart
  def create
  end
  
  # POST /cart/add_item
  def update_item
  end

  # DELETE /cart/:product_id
  def remove_item
  end

  private
    def cart_params
      params.permit(:product_id, :quantity)
    end
end
