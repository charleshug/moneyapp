class Trx < ApplicationRecord
  validates :date, presence: true
  belongs_to :account
  belongs_to :category
  belongs_to :vendor
end
