class Vendor < ApplicationRecord
  validates :name, presence: true

  has_many :trxes
end
