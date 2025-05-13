class State < ApplicationRecord
  belongs_to :country
  has_many :checkouts

  validates :name, presence: true
  validates :name, uniqueness: {scope: :country_id, case_sensitive: false }
  validates :country_id, presence: true
end
