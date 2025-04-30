class Admin::ProductsController < ApplicationController
  http_basic_authenticate_with name: 'admin', password: 'pw'
  before_action :set_product, only: %i[show edit update destroy]
  def index
    @products = Product.includes(image_attachment: :blob).all
  end

  def show; end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path, notice: '商品を登録しました'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @product.update(product_params)
      redirect_to admin_products_path(@product), notice: '更新しました'
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: '商品を削除しました'
  end

  private

  def set_product
    @product = Product.includes(image_attachment: :blob).find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image)
  end
end
