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

  def apply_promo_code(code)
    # 有効なcodeを探す
    promotion_code = PromotionCode.find_by(code: code, active: true, used: false)
    if promotion_code
      apply_discount(promotion_code.discount_amount)
      # カートにコードの文字列を保存
      update(promotion_code: promotion_code.code)
      promotion_code.update(used: true) # DB更新 使い切り
      # 戻り値をハッシュで返す と意味が明確。情報を複数送ることもできる
      { success: true }
    else
      { success: false, message: '無効なプロモーションコードです' }
    end

    redirect_to cart_path
  end

  # 割引適用
  def apply_discount(amount)
    # 自身のDBを更新
    update(discount_amount: amount)
  end

  def subtotal_price
    cart_items.sum { |item| item.product.price * item.quantity }
  end

  def total_price
    subtotal_price
    [subtotal_price - (discount_amount || 0), 0].max # 0以下になったら0にする
  end

  private

  # 指定された商品に対応するカートアイテムを検索する
  def find_item_by_product(product)
    cart_items.find_by(product:)
  end
end
