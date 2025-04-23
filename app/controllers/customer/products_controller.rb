class Customer::ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
    @related_products = Product.order(created_at: :desc)
                               .where.not(id: @product.id)
                               .limit(4)
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image)
  end
end
