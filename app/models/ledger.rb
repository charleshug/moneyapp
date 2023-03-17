class Ledger < ApplicationRecord
  belongs_to :category

  validates :date, uniqueness: { scope: :category, message: "Category already exists for this date." }
  validate :first_of_month

  before_validation :set_date_to_first_of_month
  before_save :recalculate
  after_create :initialize_balances
  after_save :recalc_forward_if_changes_to_carried_balance
  
  scope :date, -> (date) { where(date: date )}
  scope :date_thru, -> (date) { where("date < ?", date )}
  scope :negative_end_balance, -> { where("end_balance < 0")}
  scope :carry_forward_negative, -> { where(carry_forward_negative_balance: true  )}
  scope :not_carry_forward_negative, -> { where(carry_forward_negative_balance: false  )}
  scope :category_id, -> (id) { where(category_id: id )}

  # def self.line_effect(line, effect = "add")
  #   #find ledger
  #   return false unless ledger = Ledger.find_by(date: line.trx.date, category: line.category)
  #   #determine line_type budget/actual
  #   line.is_budget? ? amount_type="budget" : amount_type="actual"
  #   #reduce ledger by amount
  #   if effect=="remove"
  #     ledger.decrement!(amount_type, line.amount )
  #   else
  #     ledger.increment!(amount_type, line.amount )
  #   end
  #   ledger.recalc_forward
  #   ledger
  # end

  def check_carry_status
    carry_forward_negative_balance != carry_forward_negative_balance_before_last_save
    recalc_carried_bal
    recalc_forward
  end

  # def carried_balance_less_than_zero
  #   carried_balance <= 0
  # end

  def first_of_month
    errors.add("Date must be first of the month") unless date.day == 1
  end

  def recalc_beginning_bal
    #puts "DEBUG: #{__method__.to_s}"
    temp_beg_bal = ( previous_item&.carried_balance || 0 )
    self.update_column(:beginning_balance, temp_beg_bal) if (temp_beg_bal != beginning_balance)
  end

  def recalc_net
    #puts "DEBUG: #{__method__.to_s}"
    temp_net = budget + actual
    self.update_column(:net, temp_net) if ( net != temp_net )
  end

  def recalc_end_bal
    #puts "DEBUG: #{__method__.to_s}"
    temp_end_balance = (previous_item&.carried_balance || 0) + net
    self.update_column(:end_balance, temp_end_balance) if ( end_balance != temp_end_balance )
  end

  def recalc_carried_bal
    #puts "DEBUG: #{__method__.to_s}"
    temp_carried_balance = get_carried_balance
    self.update_column(:carried_balance,temp_carried_balance) if ( carried_balance != temp_carried_balance )
  end

  def get_carried_balance
    (carry_forward_negative_balance || end_balance >= 0) ? end_balance : 0
  end

  def initialize_balances
    #puts "DEBUG: #{__method__.to_s}"
    recalc_beginning_bal
    recalc_net
    recalc_end_bal
    recalc_carried_bal
  end
  
  def self.recalc_from(date, category)
    ledgers = Ledger.where(category:category).where('date > ?', date)
    ledgers.each do |ledger|
      ledger.recalc_net
      ledger.recalc_end_bal
      ledger.recalc_carried_bal
    end
  end

  def recalc_forward
    return false unless next_item
    #similar to self.recalc_from()
    ledgers = Ledger.where(category:category).where('date > ?', date)
    ledgers.each do |ledger|
      ledger.recalc_beginning_bal
      ledger.recalc_net
      ledger.recalc_end_bal
      ledger.recalc_carried_bal
    end
  end
  
  def recalc_forward_if_changes_to_carried_balance
    #no action if changes don't carryforward to next ledger
    return if previous_changes.slice(:carried_balance).empty?
    #no action if no future ledger exists yet
    return unless ledger = next_item
    ledger.recalculate
    ledger.save!
  end

  def previous_item
    list = Ledger.where(category_id: category.id)
                 .where("date < ?", date)
                 .order(:date)
    return nil unless list.size > 0
    list.last
  end

  def self.first_item(category)
    list = Ledger.where(category: category)
                 .order(:date)
    return nil if list.empty?
    list.first
  end
    
  def self.closest_previous(date, category)
    list = Ledger.where(category: category)
                 .where("date < ?", date)
                 .order(:date)
    return nil unless list.size > 0
    list.last
  end

  def next_item
    list = Ledger.where(category_id: category.id)
                 .where("date > ?", date)
                 .order(date: :desc)
    return nil unless list.size > 0
    list.last
  end

  def self.closest_next(date, category)
    list = Ledger.where(category: category)
                  .where("date > ?", date)
                 .order(date: :desc)
    return nil unless list.size > 0
    list.last
  end

  def recalculate
    #puts "DEBUG: #{__method__.to_s}"
    self.beginning_balance = previous_item&.carried_balance || 0
    self.net = budget + actual
    self.end_balance = beginning_balance + net

    #carry_forward_negative_balance? ? temp = end_balance : temp = [0,end_balance].max
    self.carried_balance= get_carried_balance
  end

  def self.recalculate_all
    #puts "DEBUG: #{__method__.to_s}"
    Ledger.pluck(:category_id).uniq.each do |category|
      list = Ledger.where(category: category).order(:date)
      list.each do |ledger|
        ledger.recalc_net
        ledger.recalc_end_bal
        ledger.recalc_carried_bal
      end
    end
  end

  def self.update_ledger(date,category,delta_amount,area_string)
      ledger = Ledger.find_or_create_by!(category: category, date: date.beginning_of_month)

      ledger.increment!(area_string, delta_amount)
      ledger.recalc_net
      ledger.recalc_end_bal
      ledger.recalc_carried_bal
      ledger.recalc_forward
  end

def self.update_ledger_from_trx(trx)
    puts "#{__method__.to_s}"
    changes = trx.previous_changes.slice(:id,:date,:category_id,:amount)
    return if changes.empty?
    return unless trx.lines.empty?

    trx.is_budget? ? balance_type = :budget : balance_type = :actual

    if changes[:id]
      #brand new trx
      ledger = Ledger.find_or_create_by(date: trx.date.beginning_of_month, category_id: trx.category_id)
      ledger.increment!(balance_type, trx.amount)
      return
    end

    #only the amount changed
    if changes[:amount] && changes[:date].nil? && changes[:category_id].nil?
      ledger = Ledger.find_by(date: trx.date.beginning_of_month, category_id: trx.category_id)
      amount_delta = trx.amount - changes[:amount][0]
      ledger.update_attribute(balance_type, amount_delta)
      return
    end

    #date or category changed and optionally amount, too
    puts "THIRD OPTION"
    changes[:date] && changes[:date][0]               ? prev_date   = changes[:date][0]        : prev_date    = trx.date
    changes[:category_id] && changes[:category_id][0] ? prev_cat    = changes[:category_id][0] : prev_cat     = trx.category_id
    changes[:amount]                                  ? prev_amount = changes[:amount][0]      : prev_amount  = trx.amount

    prev_ledger = Ledger.find_by(date: prev_date.beginning_of_month, category_id: prev_cat)
    prev_ledger.decrement!(balance_type, prev_amount)

    new_ledger = Ledger.find_or_create_by(date: trx.date.beginning_of_month, category_id: trx.category_id)
    new_ledger.increment!(balance_type, trx.amount)
    return
  end

  def set_date_to_first_of_month
    if date != date.beginning_of_month
      self.date = date.beginning_of_month
    end
  end

end
