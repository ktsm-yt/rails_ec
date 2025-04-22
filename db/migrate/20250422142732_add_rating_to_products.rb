class AddRatingToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :rating, :integer
  end
end
