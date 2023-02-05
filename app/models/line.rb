class Line < ApplicationRecord
  belongs_to :trx
  belongs_to :category
end
