class Product < ApplicationRecord
  with_options presence: true do
    validates :name
    validates :description
    validates :stock
    validates :image
    validates :price
  end
  has_one_attached :image # Active recode
  has_many :cart_items, dependent: :destroy

  def discounted?
    original_price.present? && original_price > price
  end

  def price_range?
    original_price.present? && (price != original_price)
  end

  # original_priceが存在するとき,validateを執行する。
  validate :validate_original_price, if: -> { original_price.present? }

  private

  # validationを変更
  def validate_original_price
    return unless original_price < price

    errors.add(:original_price, 'は現在価格以上の金額を設定してください')
  end
  
end
