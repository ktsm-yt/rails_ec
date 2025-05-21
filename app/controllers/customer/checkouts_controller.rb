class Customer::CheckoutsController < ApplicationController
  before_action :set_current_cart, only: :create

  # continue to checkout
  def create
    if @current_cart.nil? || @current_cart.cart_items.empty?
      redirect_to cart_path, alert: 'カートが空か,無効です'
      return
    end
    @checkout = @current_cart.build_checkout(checkout_params)
  
    if @checkout.save
      begin
        OrderProcessor.new(checkout: @checkout, cart: @current_cart).call
        redirect_to products_path, notice: '購入ありがとうございます'
      rescue StandardError => e
        log_error(e)
        flash.now[:alert] = '注文処理中にエラーが発生しました。もう一度お試しください。'
        redirect_to cart_path
      end
    else
      # PRGパターン
      # フォームデータをセッションに保存
      session[:checkout_params] = checkout_params
      flash[:alert] = @checkout.errors.full_messages.join('<br>')
      redirect_to cart_path
    end
  end

  private

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
      credit_card_attributes: %i[
        name_on_card
        card_number
        expiration_month
        expiration_year
        cvv
      ]
    )
  end

  def log_error(exception)
    Rails.logger.error "Order creation failed: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
  end
end
