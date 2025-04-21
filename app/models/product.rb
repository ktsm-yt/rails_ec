class Product < ApplicationRecord
with_options presence: true do
  validates :name
  validates :description
  validates :price
  validates :stock
end
has_one_attached :image #Active recode
end
