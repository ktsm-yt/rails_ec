class AddNullConstraintToCartItemQuantity < ActiveRecord::Migration[7.0]
  def change
    change_column :cart_items, :quantity, :integer, null: false, default: 1
  end
end
