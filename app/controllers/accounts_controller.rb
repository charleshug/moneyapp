class AccountsController < ApplicationController
  def index
    session[:page]="Accounts"
    @accounts = Account.not_budget_type
    @accounts_onBudget = @accounts.open.on_budget
    @accounts_offBudget = @accounts.open.off_budget
    @accounts_closed = @accounts.closed
  end

  def show
    @account = Account.find(params[:id])
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      redirect_to accounts_path
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    if @account.update(account_params)
      redirect_to accounts_path
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    redirect_to accounts_path, status: :see_other
  end

  def update_position
    @account = Account.find(params[:id])
    @account.insert_at(account_params[:position].to_i)
    head :ok
  end

  private
    def account_params
      params.require(:account).permit(:name, :balance, :on_budget, :closed,
                                           :starting_balance, :starting_date, :position)
    end
end
