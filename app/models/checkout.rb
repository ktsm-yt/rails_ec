class Checkout < ApplicationRecord
  belongs_to :countries
  belongs_to :state
  has_one :credit_card, dependent: :destroy

  # todo 一つのbuttonから2つのモデルcreditとcheckoutを取ってこなきゃならない
  # CreditCardの属性をCheckoutフォームからまとめて受け取れるようにする
  accepts_nested_attributes_for :credit_card

  # フォームで受け取った関連のバリデーションチェック
  validates_associated :credit_card
  # 自身へのチェック 
  # validate
  ## 注文,在庫,支払いetc
end
