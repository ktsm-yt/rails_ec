class AddCartRefToCheckouts < ActiveRecord::Migration[7.0]
  def change
    add_reference :checkouts, :cart, null: false, foreign_key: true
  end
end
