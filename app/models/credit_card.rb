class CreditCard < ApplicationRecord
  belongs_to :checkout
  attr_accessor :cvv

  with_options presence: true do
    validates :name_on_card
    validates :card_number, numericality: { only_integer: true }, length: { is: 16 }
    validates :expiration_month, numericality: { only_integer: true }
    validates :expiration_year, numericality: { only_integer: true }
    validates :cvv, numericality: { only_integer: true }, length: { in: 3..4 }
  end
end
