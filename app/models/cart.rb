class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :session_id, presence: true, uniqueness: true

  def add_product(product, quantity = 1)
    current_item = find_item_by_product(product)

    if current_item
      current_item.quantity += quantity
      current_item.save # 保存しないと更新で消える
    else
      cart_items.build(product:, quantity:)
    end
  end

  def remove_product(product)
    current_item = find_item_by_product(product)

    return unless current_item # アイテムが存在するか

    if current_item.quantity > 1
      current_item.quantity -= quantity
      current_item.save # 数量が2以上の場合は1減らす
    else
      current_item.destroy # 数量が1の場合はアイテムを削除
    end
  end

  def total_price
    cart_items.sum { |item| item.product.price * item.quantity }
  end

  private

  # 指定された商品に対応するカートアイテムを検索する
  def find_item_by_product(product)
    cart_items.find_by(product:)
  end
end
