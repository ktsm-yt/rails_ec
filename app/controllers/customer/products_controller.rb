class Customer::ProductsController < ApplicationController
  before_action :set_current_cart, :set_cart_items
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
  
  def set_current_cart
    @current_cart = Cart.find_or_create_by(session_id: session.id.to_s)
  end

  def set_cart_items
    @cart_items = @current_cart.cart_items
  end
end
