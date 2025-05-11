class Country < ApplicationRecord
  has_many :state
  has_many :checkouts
end
