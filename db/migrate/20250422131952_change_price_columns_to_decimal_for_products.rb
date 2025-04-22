class ChangePriceColumnsToDecimalForProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :price, :integer

    add_column :products, :price, :decimal, precision:10, scale:2
    add_column :products, :original_price, :decimal, precision:10, scale:2
  end
end
