class BudgetsController < ApplicationController
  def index
    if params[:period]
      @given_date = (params[:period] + "-01").to_date.beginning_of_month
      session[:period]=@given_date
    elsif session[:period]
      @given_date = session[:period].to_date
    else
      @given_date = Date.today.beginning_of_month
      session[:period]=@given_date
    end

    session[:page]="Budgets"

    @currentData = getBudgetData(@given_date)
  end
end
