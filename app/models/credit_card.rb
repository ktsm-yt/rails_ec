class CreditCard < ApplicationRecord
  belongs_to :checkout

  with_options presence: true do
    validates :name_on_card
    validates :card_number, numericality: { only_integer: true }
    validates :expiration_month, numericality: { only_integer: true }
    validates :expiration_year, numericality: { only_integer: true }
  end
end
