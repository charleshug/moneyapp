class Line < ApplicationRecord
  LINE_TYPES = %w(Expense Budget Income Transfer Various).freeze

  validates :amount, presence: true
  validates :line_type, inclusion: { in: LINE_TYPES }
  belongs_to :trx
  belongs_to :category

end
