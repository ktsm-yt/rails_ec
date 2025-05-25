class Customer::CheckoutsController < ApplicationController
  before_action :set_current_cart, only: :create
  before_action :ensure_cart_has_items, only: :create

  def create
    @checkout = @current_cart.build_checkout(checkout_params)

    if @checkout.save
      process_order
    else
      handle_checkout_errors
    end
  end

  private

  def ensure_cart_has_items
    return if @current_cart&.cart_items&.any? # ぼっち nilが出てもエラーを出さずnilを返す。

    redirect_to cart_path, alert: 'カートが空か,無効です'
  end

  def process_order
    result = OrderProcessor.new(checkout: @checkout, cart: @current_cart).call

    if result[:success]
      redirect_to products_path, notice: '購入ありがとうございます'
    else
      redirect_to cart_path, alert: '注文処理中にエラーが発生しました。もう一度お試しください。'
    end
  end

  # PRGパターン
  # フォームデータをセッションに保存
  def handle_checkout_errors
    session[:checkout_params] = checkout_params
    redirect_to cart_path, alert: @checkout.errors.full_messages.join('\n')
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
