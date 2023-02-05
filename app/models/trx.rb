class Trx < ApplicationRecord
  validates :date, presence: true
  belongs_to :account
  belongs_to :category
  belongs_to :vendor

  has_many :lines, dependent: :destroy
  accepts_nested_attributes_for :lines, allow_destroy: true
end
