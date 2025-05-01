class Customer::CartController < ApplicationController
  before_action :set_cart_items, only: %i[update remove_item]
  def index
    @cart_items = @current_cart.cart_items.includes(:product) # N+1
  end
  # current_cartは現在のユーザーセッションに関連付けられているカートobj
  def add_item
    product = Product.find(params[:product_id]) # Product.objを見つけ
    @current_cart.add_product(product) # Cartクラスのメソッド
    @current_cart.save # DBへ保存し,カートを離れても有効に

    redirect_to customer_cart_path, notice: '商品をカートに追加しました'
  end

  def update_item # カートの数値の直接更新
    cart_item = @current_cart.cart_items.find(params[:id])

    if params[:quantity] > 0
      cart_item.update(quantity: params[:quantity])
      flash[:notice] = '数量を更新しました'
    else
      cart_item.destroy
      flash[:notice] = 'カートから商品を削除しました'
    end

    redirect_to customer_cart_path
  end

  def remove_item # ゴミ箱ボタンにするか
    cart_item = @current_cart.cart_items.find(params[:id])
    cart_item.destroy

    redirect_to customer_cart_path, notice: 'カートから商品を削除しました'
  end

  def destroy # 全削除
    @current_cart.cart_items.destroy_all
    redirect_to customer_cart_path, notice: 'カートを空にしました'
  end



  private

  def set_cart_item
    @cart_item = @current_cart.cart_items.find(params[:id])
  end
end
