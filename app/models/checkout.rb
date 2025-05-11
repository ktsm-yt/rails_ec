class Checkout < ApplicationRecord
  belongs_to :countries
  belongs_to :state
end
