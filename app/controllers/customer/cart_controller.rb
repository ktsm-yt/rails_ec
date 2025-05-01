class Customer::CartController < ApplicationController
  before_action :set_cart_item, only: %i[update remove_item]
  def index
    @cart_items = @current_cart.cart_items.includes(:product) # N+1
  end
  # current_cartは現在のユーザーセッションに関連付けられているカートobj
  def add_item
    product = Product.find(params[:product_id]) # Product.objを見つけ
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1 # nilなら1に
    @current_cart.add_product(product, quantity) # 数量を渡してadd_productを呼び出し
    @current_cart.save # DBへ保存し,カートを離れても有効に

    redirect_to customer_cart_path, notice: '商品をカートに追加しました'
  end

  def update_item # カートの数値の直接更新
    cart_item = @current_cart.cart_items.find(params[:id])
    quantity = params[:quantity].to_i

    if quantity > 0
      # 数量更新に変換したquantityを使用
      if cart_item.update(quantity: quantity)
        flash[:notice] = '数量を更新しました'
      else
        # 更新に失敗したとき
        flash[:alert] = cart_item.errors.full_messages.join(", ") # エラーメッセージを表示
      end
    else
      cart_item.destroy
      flash[:notice] = 'カートから商品を削除しました'
    end

    redirect_to customer_cart_path
  end

  def remove_item 
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
