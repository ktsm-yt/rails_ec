class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :session_id, presence: true, uniqueness: true

  def add_product(product)
    current_item = cart_items.find_by(product: product)

    if current_item
      current_item.increment!(:quantity)
    else
      current_items = cart_items.build(product: product, quantity: 1)
    end
  end

  def total_price
    cart_items.sum {|item| item.product.price * item.quantity }
  end
end
