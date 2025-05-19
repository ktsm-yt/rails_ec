class Country < ApplicationRecord
  has_many :states, dependent: :destroy
  has_many :checkouts, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
