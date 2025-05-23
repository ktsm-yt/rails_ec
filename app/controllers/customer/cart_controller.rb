class Customer::CartController < ApplicationController
  include Customer::CheckoutFormHandler

  before_action :set_current_cart
  before_action :set_cart_item, only: %i[update_item remove_item]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def show
    @cart_items = @current_cart.cart_items.includes(:product).order(created_at: :asc)
    set_location_data
    initialize_checkout_form
  end

  # current_cartは現在のユーザーセッションに関連付けられているCartのobj
  def add_item
    product = Product.find(params[:product_id]) # Product.objを見つけ
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1 # nilなら1に

    @current_cart.add_product(product, quantity) # 数量を渡してCartクラスのadd_productを呼び出し
    @current_cart.save # DBへ保存し,カートを離れても有効に

    redirect_to root_path, notice: "「#{product.name}」をカートに追加しました"
  end

  # カートの数値の直接更新
  def update_item
    quantity = params[:quantity].to_i

    return unless update_cart_item_quantity(quantity)

    save_checkout_data_to_session
    redirect_to cart_path
  end

  def remove_item
    @cart_item.destroy
    redirect_to cart_path, notice: 'カートから商品を削除しました'
  end

  def destroy
    @current_cart.cart_items.destroy_all
    redirect_to root_path, notice: 'カートを空にしました'
  end

  def apply_promo_code
    result = @current_cart.apply_promo_code(params[:promo_code])

    # ハッシュで呼び出すと必要情報を柔軟に取り出せる。
    if result[:success]
      flash[:notice] = 'プロモーションコードを適用しました！'
    else
      flash[:alert] = result[:message] || '無効なプロモーションコードです'
    end

    redirect_to cart_path
  end

  private

  # 必然性のある項目なので例外の出るfindをあえて利用
  def set_cart_item
    @cart_item = @current_cart.cart_items.find(params[:id])
  end

  # Product.find または CartItem.find で ActiveRecord::RecordNotFound が発生した場合
  def handle_record_not_found
    redirect_to cart_path, alert: '指定されたアイテムは見つかりませんでした'
  end

  def update_cart_item_quantity(quantity)
    if quantity.positive?
      if @cart_item.update(quantity:)
        flash[:notice] = '数量を更新しました'
      else
        flash[:alert] = @cart_item.errors.full_messages.join(', ') # エラーメッセージを表示
      end
    else
      @cart_item.destroy
      flash[:notice] = 'カートから商品を削除しました'
    end
  end
end
