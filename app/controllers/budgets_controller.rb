class BudgetsController < ApplicationController
  def index
    if params[:period]
      @given_date = (params[:period] + "-01").to_date.beginning_of_month
      #@given_date = params[:period].to_date.beginning_of_month
      session[:period]=@given_date
    elsif session[:period]
      @given_date = session[:period].to_date
    else
      @given_date = Date.today.beginning_of_month
      session[:period]=@given_date
    end

    session[:page]="Budgets"
    
    @current_year = @given_date.year
    @current_month = @given_date.month

    @previous_date = @given_date << 1
    @previous_year = @previous_date.year
    @previous_month = @previous_date.month

    @next_date = @given_date >> 1
    @next_year = @next_date.year
    @next_month = @next_date.month

    #@previousData = getBudgetData(@previous_date)
    @currentData = getBudgetData(@given_date)
    #@futureData = getBudgetData(@next_date)
  end
end
