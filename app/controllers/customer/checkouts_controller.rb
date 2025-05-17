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
        ActiveRecord::Base.transaction do
          # Orderの作成 checkoutからデータ取得
          @order = Order.create!(
            customer_name: "#{@checkout.first_name} #{@checkout.last_name}",
            customer_email: @checkout.email,
            total_price: 0
            )
          total_price = 0
          # CartItemからOrderItemを作成し、購入時点の情報を保存
          @current_cart.cart_items.includes(:product).each do |cart_item| # Product情報もまとめて取得
            product = cart_item.product # 元の商品情報
            item_price = product.price * cart_item.quantity
            total_price += item_price

            @order.order_items.create!(
              product: product, # Productへの参照 (optional: true)
              name: product.name, # 購入時点の商品名
              price: product.price, # 購入時点の価格
              quantity: cart_item.quantity
            )
          end

          # Orderの合計金額を更新
          @order.update!(total_price: total_price)

          @current_cart.cart_items.destroy_all
          
          OrderMailer.order_confirmation_email(@order).deliver_later
          redirect_to products_path, notice: '購入ありがとうございます'
        end
      rescue => e
         # ログに出力してデバッグしやすくする
         Rails.logger.error "Order creation failed: #{e.message}"
         Rails.logger.error e.backtrace.join("\n")

         flash.now[:alert] = "注文処理中にエラーが発生しました。もう一度お試しください。"
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
end
