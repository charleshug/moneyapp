class ReportsController < ApplicationController
  def index
    session[:page]="Reports"
    
    @net_worth_array = get_net_worth_for_new_worth_report
    @spending_by_category = get_category_amount_for_spending_report
    @spending_by_vendor = get_vendors_for_spending_report
  end

end
