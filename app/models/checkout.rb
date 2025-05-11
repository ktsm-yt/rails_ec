class Checkout < ApplicationRecord
  belongs_to :countries
  belongs_to :state
  has_one :credit_card, dependent: :destroy

  # CreditCardの属性をCheckoutフォームからまとめて受け取れるようにする
  accept_nested_attributes_for :credit_card

  # フォームで関連オブジェクトを作成するために必要
  validates_associated :credit_card
end
