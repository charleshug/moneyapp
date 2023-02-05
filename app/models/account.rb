class Account < ApplicationRecord
  validates :balance, presence: true
  validates :name, presence: true
  validates :on_budget, inclusion: { in: [true, false] }
  validates :closed, inclusion: { in: [true, false] }
end
