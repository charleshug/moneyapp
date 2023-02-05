class Line < ApplicationRecord
  LINE_TYPES = %w(Expense Budget Income Transfer Various).freeze

  validates :amount, presence: true
  validates :line_type, inclusion: { in: LINE_TYPES }
  belongs_to :trx
  belongs_to :category

  before_save :set_line_type
  after_save :update_trx_amount
  after_save :update_trx_category
  after_save :update_ledger

  before_destroy :zero_amount

  scope :on_budget,       -> { where(trxes: Trx.on_budget_accounts )}
  #scope :on_budget,       -> { joins(:trx).where(trxes: {id: Trx.on_budget_items})}
  scope :incomeItems,     -> { where(line_type: "Income")}
  scope :prev_all,        -> (date)        { joins(:trx).where("date < ?", date) }
  scope :period,     -> (date)        { joins(:trx).where(trxes: {date: (date.beginning_of_month)..(date.end_of_month) })}  
  scope :date,            -> (date)        { joins(:trx).where(trxes: { date: date })}
  scope :date_thru,       -> (date)        { joins(:trx).where("date <= ?", date).order(date: :asc) }
  scope :category_id,     -> (category_id) { where(category_id: category_id)}
  scope :category,        -> (category)    { where(category: Category.find_by(name: category ))}
  scope :account,         -> (account)     { joins(:trx).where(trx: {account: Account.find_by(name: account) })}
  scope :account_id,      -> (account_id)  { joins(:trx).where(trx: {account_id: account_id })}
  
  def self.sum_of_parent(parent)
    sum=0
    parent.subcategories.each do |c|
      sum += Line.category(c.name).sum(:amount)
    end
    return sum
  end

  def is_budget?
    line_type == "Budget"
  end

  def update_ledger
    delta_amount =  amount - (amount_before_last_save || 0 )
    is_budget? ? area_string = "budget" : area_string = "actual"
    Ledger.update_ledger(trx.date, category, delta_amount, area_string)
  end

  def zero_amount
    update_attribute(:amount, 0)
  end


  private

  def get_category
    if trx.account.on_budget?
        if vendor.nil?
          if category.nil?
            new_category = "Uncategorized"
          end
        elsif vendor.account&.on_budget?
          new_category = "N/A - No category needed"
        else
          if category.nil?
            new_category = "Uncategorized"
          end
        end
    else
      new_category = "N/A - Off-Budget"
    end
    Category.find_by(name: new_category)
  end

  def determine_category
    new_category = get_category
    
    if category.nil? || new_category.name != category.name
      self.update_attribute(:category, new_category)
    end
  end

  def update_trx_category
    trx.determine_category
  end

  def update_trx_amount
    puts "DEBUG: Line:#{__method__.to_s}"
    amount_changed = amount - (amount_before_last_save || 0 )
    trx.increment_amount(amount_changed)
  end

  def set_line_type
    if line_type.nil?
      if trx.vendor&.name == "Budget" || trx.account&.name == "Budget"
        self.line_type = "Budget"
      elsif Category.find(category_id)&.parent&.name == "Income Parent"
        self.line_type = "Income"
      else
        self.line_type = "Expense"
      end
    end
  end

end
