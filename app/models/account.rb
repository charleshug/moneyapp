class Account < ApplicationRecord
  validates :balance, presence: true
  validates :name, presence: true
  validates :on_budget, inclusion: { in: [true, false] }
  validates :closed, inclusion: { in: [true, false] }

  has_many :trxes, dependent: :restrict_with_exception

  accepts_nested_attributes_for :trxes
end
