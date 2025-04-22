class Product < ApplicationRecord
  with_options presence: true do
    validates :name
    validates :description
    validates :stock
    validates :image
    validates :price
    validates :original_price
  end
  has_one_attached :image #Active recode

  def discounted?
    original_price.present? && original_price > price
  end

  def price_range?
    max_price.present? && (min_price != max_price)
  end

  def old_price_range?
    old_max_price.present? && (old_min_price != old_max_price)
  end
end
