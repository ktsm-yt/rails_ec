class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  has_one :checkout, dependent: :destroy
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

  # # 使ってないメソッド
  # def remove_product(product, quantity = 1)
  #   current_item = find_item_by_product(product)

  #   return unless current_item # アイテムが存在するか

  #   if current_item.quantity > 1
  #     current_item.quantity -= quantity
  #     current_item.save # 数量が2以上の場合は1減らす
  #   else
  #     current_item.destroy # 数量が1の場合はアイテムを削除
  #   end
  # end

  # 割引適用
  def apply_discount(amount, _ = nil)
    # 自身のDBを更新
    self.discount_amount = amount
    promotion_code
    save
  end

  def promotion_code_object
    PromotionCode.find_by(code: promotion_code) if promotion_code.present?
  end

  def total_price
    subtotal = cart_items.sum { |item| item.product.price * item.quantity }
    [subtotal - (discount_amount || 0), 0].max # 0以下になったら0にする
  end

  private

  # 指定された商品に対応するカートアイテムを検索する
  def find_item_by_product(product)
    cart_items.find_by(product:)
  end
end
