class Account < ApplicationRecord
  validates :balance, presence: true
  validates :name, presence: true
  validates :on_budget, inclusion: { in: [true, false] }
  validates :closed, inclusion: { in: [true, false] }

  has_many :trxes, dependent: :restrict_with_exception

  accepts_nested_attributes_for :trxes

  after_create :create_starting_transaction
  attr_accessor :starting_balance, :starting_date

  scope :open,   -> { where(closed: false) }
  scope :closed, -> { where(closed: true) }
  scope :on_budget, -> { where(on_budget: true) }
  scope :off_budget, -> { where(on_budget: false) }
  scope :not_budget_type, -> { where.not(name: "Budget")}

  def self.for_select
    {
    'On-Budget'    => where(on_budget: true).map     { |p| [p.name, p.id] },
    'Off-Budget'   => where.not(on_budget: true).map { |p| [p.name, p.id] },
    }
  end

  def self.recalculate_all_balances
    Account.all.each do |account|
      account.recalculate_balance
    end
  end

  def self.update_account_from_trx(trx)
    changes = trx.previous_changes.slice(:id,:amount,:account_id)

    if changes[:id]
      trx.account.increment!(:balance, trx.amount)

    elsif changes[:account_id] && changes[:amount]
      old_account = Account.find changes[:account_id][0]
      new_account = Account.find changes[:account_id][1]
      old_account.decrement!(:balance, changes[:amount][0])
      new_account.increment!(:balance, changes[:amount][1])
    elsif changes[:account_id]
      old_account = Account.find changes[:account_id][0]
      new_account = Account.find changes[:account_id][1]
      old_account.decrement!(:balance, trx.amount)
      new_account.increment!(:balance, trx.amount)
    elsif changes[:amount]
      delta_amount = changes[:amount][1] - changes[:amount][0]
      trx.account.increment!(:balance, delta_amount)
    else
      puts "SHOULDN'T REACH THIS"
    end
  end

  def recalculate_balance
    trxes = Trx.where(account: self)
    balance = trxes.sum(:amount)
    self.update_attribute(:balance, balance)
  end

  def increment_balance(delta_balance)
    new_balance = balance + delta_balance
    puts "DEBUG: Account:#{__method__.to_s}, #{name}, current balance #{balance}, balance before last save #{balance_before_last_save}, new balance #{new_balance}, delta #{delta_balance}"
    self.update_attribute(:balance,new_balance)
  end  

  def create_starting_transaction
    puts "DEBUG: Account:#{__method__.to_s}"
    if starting_balance.to_i != 0
      Trx.create_starting_transaction( { date: starting_date,
                                         amount: starting_balance,
                                         account: self } )
    end
  end
  
end
