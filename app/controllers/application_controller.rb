# frozen_string_literal: true

class ApplicationController < ActionController::API
  private
    def current_cart
      @current_cart ||= Cart.find_or_create_by(id: session[:cart_id]).tap do |cart|
        session[:cart_id] ||= cart.id
      end
    end
end
