module ReportsHelper

  def get_net_worth
    #builds a hash of Period => Sum, then .maps so each month represents the rolling balance, then reduces it from hash to array
    sum=0
    Trx.registerItems.group_by_month(:date, format: '%b %Y').sum(:amount).map { |x,y| { x => (sum += y)} }.reduce({}, :merge)
  end
end
