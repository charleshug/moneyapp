class Trx < ApplicationRecord
  require 'csv'

  validates :date, presence: true
  belongs_to :account
  belongs_to :category
  belongs_to :vendor

  has_many :lines, dependent: :destroy
  accepts_nested_attributes_for :lines, allow_destroy: true

  before_save :update_trx_amount_from_lines, if: :is_split_trx
  after_save :update_account_balance
  after_save :update_ledger, unless: :is_split_trx
  after_destroy :remove_from_account_balance
  before_destroy :zero_amount

  scope :budgetItems,           ->                   { where(accounts: Account.find_by(name: "Budget"))}
  scope :registerItems,         ->                   { where.not(accounts: Account.find_by(name: "Budget"))}
  scope :nonIncome,             ->                    {where.not(categories: Category.income)}
  
  scope :on_budget_accounts,    ->                   { where(account: Account.on_budget ) }
  scope :off_budget_accounts,   ->                   { where(account: Account.off_budget ) }
  scope :open_accounts,         ->                   { where(account: Account.open ) }
  scope :closed_accounts,       ->                   { where(account: (Account.closed && Account.not_budget_type) ) }
  
  scope :period,               -> (start_date, end_date = start_date) { where(date: (start_date.beginning_of_month)..(end_date.end_of_month) )}
  scope :date,                  -> (date)            { where(date: date )}
  scope :date_thru,             -> (date)            { where("date <= ?", date).order(date: :asc) }
  scope :account,               -> (account_name)    { where(account: Account.find_by(name: account_name))}
  scope :account_id,            -> (account_id)      { where(accounts: Account.find(account_id)) }
  scope :category,              -> (category_name)   { where(categories: Category.find_by(name: category_name))}
  
  scope :category_id,           -> (category_id)     { where(lines: Line.where(category_id: category_id)).or(where(category_id: category_id)) }
  
  scope :parent_id,             -> (parent_id)       { where(categories: Category.parent_id(parent_id))}
  scope :vendor_id,             -> (vendor_id)       { where(vendors: Vendor.find(vendor_id)) }
 
  def self.period2(year:,month:)
    where(date: (Date.new(year,month).beginning_of_month)..(Date.new(year,month).end_of_month))
  end

  
  def self.import(file)
    puts "DEBUG: Trx:#{__method__.to_s}"
    temp_table = CSV.read(file,headers:true)
    temp_account_list = temp_table["Account"].uniq
    return false unless temp_account_list.all? { |a| Account.find_by(name: a) }
      
      CSV.foreach(file, headers: true) do |row|
        temp = { date: Date.parse(row["Date"]),
                 memo: row["Memo"],
                 category: (Category.find_by(name: row["Category"]) || Category.find_or_create_by(name: "Uncategorized")),
                 vendor: Vendor.find_or_create_by(name: row["Vendor"]),
                 account: (Account.find_by(name: row["Account"]) ),
                 amount: row["Amount"]
                }
        Trx.create!(temp)
      end
  end
  
  def self.create_starting_transaction(args)
    puts "DEBUG: Trx:#{__method__.to_s}"
    args.merge!(memo: "Starting balance",
                vendor: Vendor.find_or_create_by(name: "Starting balance"),
                category: Category.find_or_create_by(name: "Income")
                )
    Trx.create!(args)
  end

  def self.create_single_line(args)
    puts "DEBUG: Trx:#{__method__.to_s}"
    t = Trx.new(date: args[:date],
                memo: args[:memo],
                vendor: args[:vendor],
                category: args[:category],
                account: args[:account]
              )
    t.lines.build(amount: args[:amount],
                  category: args[:category]
                  )
    t.save!
  end
  
  def self.determine_all_categories
    Trx.all.each do |trx|
      trx.determine_category
    end
  end

  def is_split_trx
    !lines.empty?
  end
  
  def update_trx_amount_from_lines
    #lines_total = lines.sum(:amount) #doesn't work if the trx/lines aren't in database
    lines_total = 0
    lines.each do |line|
      lines_total += line.amount
    end
    return nil if amount == lines_total
    #self.update_column(:amount, lines_total)
    self.amount = lines_total #no need to save because this is called before_save
  end  

  def get_category
    if lines.size > 1 
      Category.find_by(name: "Split") 
    else
      lines.first.category
    end
  end

  def determine_category
    new_category = get_category
    if new_category != category
      self.update_attribute(:category, new_category)
    end
  end

  def increment_amount(delta_amount)
    puts "DEBUG: Trx:#{__method__.to_s}"
    new_amount = amount + delta_amount
    if new_amount != amount
      self.update_attribute(:amount,new_amount)
    end
  end

  def zero_amount
    update_attribute(:amount, 0)
  end

  private

  def remove_from_account_balance
    account.increment_balance(-amount)
  end

  def update_account_balance
    return unless previous_changes.slice(:amount,:account_id)
    Account.update_account_from_trx(self)
    # amount_changed = amount - (amount_before_last_save || 0 )
    # puts "DEBUG: Trx:#{__method__.to_s}, #{account.name}, account bal: #{account.balance}, amount_changed: #{amount_changed} = new amount #{amount} - amount before last save #{amount_before_last_save}"
    
    # account.increment_balance(amount_changed)
  end

  def is_budget?
    get_type == "Budget"
  end

  def get_type
    if account&.name == "Budget"
      "Budget"
    elsif Category.find(category_id)&.parent&.name == "Income Parent"
      "Income"
    else
      "Expense"
    end
  end

  def update_ledger
    delta_amount =  amount - (amount_before_last_save || 0 )
    is_budget? ? area_string = "budget" : area_string = "actual"
    Ledger.update_ledger(date, category, delta_amount, area_string)
  end


end