class ReportsController < ApplicationController
  def index
    session[:page]="Reports"
    
    sum=0
    @net_worth_array = Trx.registerItems
                          .group_by_month(:date, format: '%b %Y')
                          .sum(:amount)
                          .map { |x,y| { x => (sum += y/100.0).round(2) } }
                          .reduce({}, :merge)

    @spending_by_category = Category.joins(subcategories: :trxes)
                                    .merge(Trx.registerItems.nonIncome)
                                    .group(:name)
                                    .sum(:amount)
                                    .sort_by { |k,v| v }
                                    .map { |x,y| { x => (y/100.0).round(2) } }
                                    .reduce({}, :merge)

    @spending_by_vendor = Vendor.joins(:trxes)
                                    .merge(Trx.registerItems.nonIncome)
                                    .group(:name)
                                    .sum(:amount)
                                    .sort_by { |k,v| v }
                                    .map { |x,y| { x => (y/100.0).round(2) } }
                                    .reduce({}, :merge)
  end

end
