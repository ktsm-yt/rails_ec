class OrderProcessor
  attr_reader :checkout, :cart, :order, :total_price

  def initialize(checkout:, cart:)
    @checkout = checkout
    @cart = cart # checkoutに関連付けられたカートから割引情報を取得
    @total_price = 0
  end

  def call
    ActiveRecord::Base.transaction do
      create_order_from_checkout
      create_order_items
      update_order_total
      clear_cart
      send_order_confirmation_email
    end
  rescue StandardError
    raise
    # ログに出力してデバッグしやすくする
  end

  private

  # Orderの作成 checkoutからデータ取得
  def create_order_from_checkout
    @order = Order.create!(
      customer_name: "#{@checkout.first_name} #{@checkout.last_name}",
      customer_email: @checkout.email,
      total_price: 0,
      discount_amount: cart.discount_amount,
      promotion_code: cart.promotion_code
    )
  end

  # CartItemからOrderItemを作成し、購入時点の情報を保存
  def create_order_items
    @total_price = 0
    @cart.cart_items.includes(:product).find_each do |cart_item| # Product情報もまとめて取得
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
    discounted_total = @total_price - (@cart.discount_amount || 0)
    @order.update!(total_price: discounted_total)
  end

  # current_cartはPOROでは定義されてない
  # ∴application.ctrの設定は無効
  def clear_cart
    @cart.cart_items.destroy_all
    reset_promo_code
  end

  def reset_promo_code
    @cart.update!(promotion_code: nil, discount_amount: nil)
  end

  def send_order_confirmation_email
    OrderMailer.order_confirmation_email(@order).deliver_later
  end
end
