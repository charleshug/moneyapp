class LedgersController < ApplicationController
  def index    
    @ledgers = Ledger.includes(:category)
    @ledgers = @ledgers.category_id(params[:category_id].split(',')) if params[:category_id]

    if params[:sort]=="date"
      @ledgers = @ledgers.order(:date,:category_id)
    else
      @ledgers = @ledgers.order(:category_id, :date)
    end

  end

  def edit
    @ledger = Ledger.find(params[:id])
  end

  def update
    @ledger = Ledger.find(params[:id])
    if @ledger.update(ledger_params)
      @ledger.check_carry_status
      redirect_to ledgers_path
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private
  def ledger_params
    params.require(:ledger).permit(:carry_forward_negative_balance)
  end
end