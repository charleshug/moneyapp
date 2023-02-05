class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: :parent_id
  has_many :trxes
  has_many :lines

  validates :name, uniqueness: true, presence: true

  scope :top_level,     -> { where(parent_id: nil) }
  scope :bottom_level,  -> { where.not(parent_id: nil) }
  scope :not_hidden,    -> { where(hidden: false)}
  scope :hidden,        -> { where(hidden: true)}
  scope :overspend,     -> { where(overspend: true)}
  scope :income,        -> {where(name: ["Income", "Income Parent",
                                       "Available next month", 
                                       "Available this month"] )}

  scope :budget,        -> { where.not(name: ["Income", 
                                       "Income Parent",
                                       "Uncategorized Transactions", 
                                       "Off-Budget", 
                                       "Available next month", 
                                       "Available this month", 
                                       "Uncategorized", 
                                       "N/A - Off-Budget"] )}
  scope :parent_id,     -> (parent_id) { where(parent_id: parent_id)}
end
