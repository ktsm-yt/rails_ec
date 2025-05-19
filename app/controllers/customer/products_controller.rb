class Customer::ProductsController < ApplicationController
  before_action :set_current_cart, :set_cart_items
  rescue_from ActiveRecord::RecordNotFound, with: :handle_product_not_found
  def index
    @products = Product.includes(image_attachment: :blob).all
  end

  def show
    @product = Product.includes(image_attachment: :blob).find(params[:id])
    @related_products = Product.includes(image_attachment: :blob)
                               .order(created_at: :desc)
                               .where.not(id: @product.id)
                               .limit(4)
  end

  private

  def set_cart_items
    @cart_items = @current_cart.cart_items
  end

  def handle_product_not_found
    redirect_to root_path, alert: 'その商品は存在していません'
  end
end
