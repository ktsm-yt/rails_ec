class Customer::ProductsController < ApplicationController
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

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image)
  end
end
