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
      process_order_transaction
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

  def process_order_transaction
    ActiveRecord::Base.transaction do
      create_order_from_checkout
      create_order_items
      update_order_total
      clear_cart
      send_order_confirmation_email
      reset_promo_code
      redirect_to products_path, notice: '購入ありがとうございます'
    end
  rescue StandardError => e
    # ログに出力してデバッグしやすくする
    log_error(e)
    flash.now[:alert] = '注文処理中にエラーが発生しました。もう一度お試しください。'
  end

  # Orderの作成 checkoutからデータ取得
  def create_order_from_checkout
    @order = Order.create!(
      customer_name: "#{@checkout.first_name} #{@checkout.last_name}",
      customer_email: @checkout.email,
      total_price: 0
    )
  end

  # CartItemからOrderItemを作成し、購入時点の情報を保存
  def create_order_items
    @total_price = 0
    @current_cart.cart_items.includes(:product).find_each do |cart_item| # Product情報もまとめて取得
      product = cart_item.product # 元の商品情報
      item_price = product.price * cart_item.quantity
      @total_price += item_price

      @order.order_items.create!(
        product: product, # Productへの参照 (optional: true)
        name: product.name, # 購入時点の商品名
        price: product.price, # 購入時点の価格
        quantity: cart_item.quantity
      )
    end
  end

  def update_order_total
    # カートの合計金額から割引額を差し引く
    discounted_total = @total_price - (@current_cart.discount_amount || 0)
    @order.update!(total_price: discounted_total)
  end

  def clear_cart
    @current_cart.cart_items.destroy_all
  end

  def send_order_confirmation_email
    OrderMailer.order_confirmation_email(@order).deliver_later
  end

  def reset_promo_code
    @current_cart.update!(promotion_code: nil, discount_amount: nil)
  end

  def log_error(exception)
    Rails.logger.error "Order creation failed: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
  end
end
