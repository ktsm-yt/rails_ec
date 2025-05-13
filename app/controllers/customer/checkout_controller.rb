class Customer::CheckoutController < ApplicationController
  before_action :set_current_cart, only: :create
  
  # continue to checkout
  def create
    if current_cart.nil?
      redirect_to cart_path, alert: 'カートが空か,無効です'
      return
    end
    
    if 
      @checkout = checkout.find(set_params)
      @checkout.save
    else
      render cart_path
    end
  end

  def thanks_message
  end

  private

  def set_current_cart
    @current_cart = Cart.find_or_create_by(session_id: session_id.to_s)
  end

  def set_params
    params.require(:create).permit(:first_name, :last_name, :username, :email, :address1, :country_id, :state_id, :zip, :shipping_same_as_billing, :save_info_for_next_time)
  end
end
