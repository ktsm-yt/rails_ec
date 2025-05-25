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
    product = Product.find(product_params[:product_id]) # Product.objを見つけ
    quantity = [params[:quantity].to_i,1].max # -,0でも1に
    @current_cart.add_product(product, quantity) # Cartより

    if @current_cart.save # DBへ保存し,カートを離れても有効に
      redirect_to root_path, notice: "「#{product.name}」をカートに追加しました"
    else
      redirect_to root_path, alert: t('.failure', errors: @current_cart.errors.full_messages.join(', '))
    end
  end

  def update_item
    if @cart_item.update(cart_item_params)
      handle_successful_cart_operation(t('.success'), :update_item)
    else
      handle_failed_cart_operation(@cart_item.errors.full_messages.join(', '))
    end
  end

  def remove_item
    if @cart_item.destroy
      handle_successful_cart_operation(t('.success'), :remove_item)
    else
      handle_failed_cart_operation(t('.failure'))
    end
  end

  def destroy
    @current_cart.cart_items.destroy_all
    redirect_to root_path, notice: t('.success')
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

  def handle_record_not_found
    redirect_to cart_path, alert: t('errors.messages.record_not_found_item')
  end

  def handle_successful_cart_operation(message, template_name)
    load_cart_items
    @current_cart.reload

    respond_to do |format|
      format.html {redirect_to cart_path, notice: message}
      format.turbo_stream do
        flash.now[:notice] = message
        if @current_cart.cart_items.empty?
          render 'customer/cart/show'
        else
          render template_name
        end
      end
    end
  end

  def handle_failed_cart_operation(error_message)
    respond_to do |format|
      format.html { redirect_to products_path, alert: error_message }
      format.turbo_stream do
        flash.now[:alert] = error_message
        render turbo_stream: turbo_stream.update('flash-messages',
                                                partial: 'shared/flash_messages')
      end
    end
  end

  def product_params
    params.permit(:product_id, :quantity)
  end

  def cart_item_params
    params.permit(:quantity)
  end
end