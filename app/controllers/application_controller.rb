class ApplicationController < ActionController::Base
  before_action :get_account_info
  include BudgetsHelper
  include TrxesHelper
  include ReportsHelper

  def get_account_info
    @accounts = Account.not_budget_type
    @accounts_onBudget = @accounts.on_budget.open
    @accounts_offBudget = @accounts.off_budget.open
    @accounts_closed = @accounts.closed
  end
end
