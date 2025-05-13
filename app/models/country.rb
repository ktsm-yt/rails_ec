class Country < ApplicationRecord
  has_many :states
  has_many :checkouts
  
  validates :name, presence: true, uniqueness: {case_sensitive: false}
end
