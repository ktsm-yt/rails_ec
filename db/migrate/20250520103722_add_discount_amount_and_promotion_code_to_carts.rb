class AddDiscountAmountAndPromotionCodeToCarts < ActiveRecord::Migration[8.0]
  def change
    add_column :carts, :discount_amount, :decimal
    add_column :carts, :promotion_code, :string
  end
end
