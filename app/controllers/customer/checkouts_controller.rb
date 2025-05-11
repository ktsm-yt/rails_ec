class Customer::CheckoutsController < ApplicationController
  before_action :set_current_cart, only: :create
  
  # continue to checkout
  def create
  end

  def thanks_message
  end

  private

  def set_current_cart
    @current_cart = Cart.find_or_create_by(session_id: session_id.to_s)
  end
end
