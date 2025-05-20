class AddDiscountInfoToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :discount_amount, :decimal
    add_column :orders, :promotion_code, :string
  end
end
