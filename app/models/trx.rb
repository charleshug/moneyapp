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
  after_save :update_ledger
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

    ActiveRecord::Base.transaction do

      temp_table = CSV.read(file,headers:true)
      temp_account_list = temp_table["Account"].uniq
      #TODO ensure all CSV file fields are unique, no repeating Vendor, Account, Date...
      return false unless temp_account_list.all? { |a| Account.find_by(name: a) || "" }
      uncategorized = Category.find_or_create_by(name: "Uncategorized")
      temp_array = temp_table.map { |row| row.to_hash }

      temp_array.each.with_index do |row, index|
          if row["Date"]
            temp_trx = {
                date: Date.parse(row["Date"]),
                memo: row["Memo"],
                category: (Category.find_by(name: row["Category"]) || uncategorized ),
                vendor: Vendor.find_or_create_by(name: row["Vendor"]),
                account: (Account.find_by(name: row["Account"]) ),
                amount: row["Amount"]
                    }
            temp_trx = Trx.new( temp_trx )

            #check next rows for line items
            temp_line_index = index + 1
            until temp_array[temp_line_index].nil? || temp_array[temp_line_index]["Date"]
              temp_line = {
                  memo: temp_array[temp_line_index]["Memo"],
                  category: (Category.find_by(name: temp_array[temp_line_index]["Category"]) || uncategorized ),
                  amount: temp_array[temp_line_index]["Amount"]
                          }
              temp_trx.lines.build(temp_line)
              temp_line_index += 1
            end
            temp_trx.save!
            row["trx_id"] = temp_trx.id
          elsif row["Account"]
            raise ("ERROR: Trx has Account but no date")
          end
        end
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

  def is_budget?
    get_type == "Budget"
  end

  private

  def remove_from_account_balance
    account.increment_balance(-amount)
  end

  def update_account_balance
    return if previous_changes.slice(:amount,:account_id).empty?
    Account.update_account_from_trx(self)
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
    return if previous_changes.slice(:amount, :category_id, :date).empty?
    Ledger.update_ledger_from_trx(self)
  end


end