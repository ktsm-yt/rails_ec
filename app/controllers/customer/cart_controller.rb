class Customer::CartController < ApplicationController
  include Customer::CheckoutFormHandler
  before_action :set_current_cart
  before_action :load_cart_items, only: %i[show update_item remove_item ]
  before_action :set_cart_item, only: %i[update_item remove_item]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def show
    set_location_data
    initialize_checkout_form
  end

  # current_cartは現在のユーザーセッションに関連付けられているCartのobj
  def add_item
    product = Product.find(params[:product_id]) # Product.objを見つけ
    quantity = params[:quantity].to_i.positive? ? params[:quantity].to_i : 1 # nilなら1に

    @current_cart.add_product(product, quantity) # 数量を渡してCartクラスのadd_productを呼び出し
    @current_cart.save # DBへ保存し,カートを離れても有効に
    redirect_to root_path, notice: "「#{product.name}」をカートに追加しました"
  end

  # カートの数値の直接更新
  def update_item
    quantity = params[:quantity].to_i
    message, flash_type, operation_succeeded = set_update_status(@cart_item.update(quantity:))
    render_cart_response(message, flash_type, operation_succeeded)
  end

  def remove_item
    message, flash_type, operation_succeeded = set_remove_status(@cart_item.destroy)
    render_cart_response(message, flash_type, operation_succeeded)
  end

  def destroy
    @current_cart.cart_items.destroy_all
    redirect_to root_path, notice: 'カートを空にしました'
  end

  def save_checkout_draft
    checkout_data = checkout_params
    session[:checkout_params] = checkout_data.to_h if checkout_data.present?
    head :ok
  end

  private

  # 必然性のある項目なので例外の出るfindをあえて利用
  def set_cart_item
    @cart_item = @current_cart.cart_items.find(params[:id])
  end

  def load_cart_items
    @cart_items = @current_cart.cart_items.includes(:product).order(created_at: :asc)
  end

  # Product.find または CartItem.find で ActiveRecord::RecordNotFound が発生した場合
  def handle_record_not_found
    redirect_to cart_path, alert: '指定されたアイテムは見つかりませんでした'
  end

  def handle_cart_item_update(quantity)
    message, flash_type, operation_succeeded = set_update_status(@cart_item.update(quantity:))
    render_cart_response(message, flash_type, operation_succeeded)
  end

  # カートアイテム削除時のステータスを設定
  def set_remove_status(success)
    if success
      ['カートから商品を削除しました', :notice, true]
    else # 削除失敗
      ['商品の削除に失敗しました', :alert, false]
    end
  end

  # カートアイテム更新時のステータスを設定
  def set_update_status(success)
    if success
      ['数量を更新しました', :notice, true]
    else # 更新失敗
      [@cart_item.errors.full_messages.join(', '), :alert, false]
    end
  end


  # カート操作後のレスポンスをレンダリング
  def render_cart_response(message, flash_type, operation_succeeded)
    flash.now[flash_type] = message
    load_cart_items if operation_succeeded

    respond_to do |format|
      if @current_cart.cart_items.empty? && operation_succeeded
        format.html { redirect_to products_path, notice: message }
      else
        format.html { redirect_to cart_path, flash_type => message }
      end

      if operation_succeeded
        format.turbo_stream
      else # 更新失敗
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('flash-messages', partial: 'shared/flash_messages')
        end
      end
    end
  end
end
