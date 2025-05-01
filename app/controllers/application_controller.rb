# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_current_cart, :set_cart_items

  def set_current_cart
    @current_cart = Cart.find_or_create_by(session_id: session.id.to_s)
  end

  def set_cart_items
    @cart_items = @current_cart.cart_items
  end
end
