class Admin::OrdersController < ApplicationController
  http_basic_authenticate_with name: 'admin', password: 'pw' # あとで環境変数へ
  def index
    @orders = Order.includes(:order_items).order(created_at: :desc)
  end

  def show
    @order = Order.includes(:order_items).find(params[:id])
  end
  # レコード更新の必要がなければストロングパラメータは不要
end

