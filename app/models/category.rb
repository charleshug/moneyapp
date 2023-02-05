class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: :parent_id
  has_many :trxes
  has_many :lines

  validates :name, uniqueness: true, presence: true
end
