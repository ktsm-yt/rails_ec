class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true
  # 関連する商品がなくなっても存在できる。→  商品明細が生き残る
end
