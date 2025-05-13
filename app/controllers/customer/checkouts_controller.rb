class Customer::CheckoutsController < ApplicationController
  before_action :set_current_cart, only: :create
  
  # continue to checkout
  def create
    if @current_cart.nil?
      redirect_to cart_path, alert: 'カートが空か,無効です'
      return
    end
    
    @checkout = Checkout.new(checkout_params)
    @checkout.cart = @current_cart

    if @checkout.save # cvvは保存されない。DBにカラムがないもんね
      redirect_to products_path, notice: "購入ありがとうございます"
      @current_cart.cart_items.destroy_all
      return
    else
      # PRGパターン
      # フォームデータをセッションに保存
      session[:checkout_params] = checkout_params
      flash[:alert] = '入力内容に不備があります'
      redirect_to cart_path
    end
  end

  private

  def set_current_cart
    @current_cart = Cart.find_or_create_by(session_id: session.id.to_s)
  end

  def checkout_params
    params.require(:checkout).permit(
                            :first_name,
                            :last_name,
                            :username,
                            :email,
                            :address1,
                            :country_id,
                            :state_id,
                            :zip,
                            :shipping_same_as_billing,
                            :save_info_for_next_time,
                            credit_card_attributes: [
                              :name_on_card,
                              :card_number,
                              :expiration_month,
                              :expiration_year
                            ]
                            )
  end
end
