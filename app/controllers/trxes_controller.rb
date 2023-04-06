class TrxesController < ApplicationController
  def new
    session[:page]="Trxes"
    trx(new_trx_params)
    trx.account_id = params[:account_id].to_i if params[:account_id]
    render :new, status: :unprocessable_entity if request.post?
  end

  def edit
    session[:page]="Trxes"
    trx(new_trx_params)
    #render :edit, status: :unprocessable_entity if request.post?
  end

  def build
    trx(new_trx_params)
    trx.category = Category.find_by(name: "Split") #build only called when multi-line Trx, this auto-sets category to Split
    trx.lines.empty? ? 2.times{trx.lines.build } : trx.lines.build
    action = trx.persisted? ? :edit : :new
    render action, status: :unprocessable_entity
  end

  def create
    trx(new_trx_params)
    if trx.save!
      html = render_to_string(partial: 'trx', locals: {trx:trx })
      #Note: creating a Cash entry from XYZ account screen, adds the new entry to XYZ until refresh
      render turbo_stream: turbo_stream.prepend(
        'trx_details',
        partial: 'trx',
        locals: { trx: trx }
      )
      #redirect_to trxes_path, notice: "Saved!"
    else
      trx.errors.full_messages.each do |e|
        puts "DEBUG Trx Error: #{e}"
      end
      render :new
    end
  end

  def update
    trx(new_trx_params)
    if trx.save!
      html = render_to_string(partial: 'trx', locals: {trx:trx })
      render turbo_stream: turbo_stream.replace(
        helpers.dom_id(trx),
        partial: 'trx',
        locals: { trx: trx }
      )
      #redirect_to trxes_path, notice: "Saved!"
    else
      trx.errors.full_messages.each do |e|
        puts "DEBUG Trx Error: #{e}"
      end
      render :new
    end
  end

  def destroy
    @trx = Trx.find(params[:id])
    @trx.destroy
    render turbo_stream: turbo_stream.remove(@trx)
    #redirect_to trxes_path, status: :see_other
  end

  def import
    Trx.import(params[:file])
    redirect_to trxes_path, notice: "Success!"
  end

  def index
    session[:page]="Accounts"

    if params[:account_id] && params[:account_id] == ""
      session[:account_id] = nil
    else
      session[:account_id]  = (params[:account_id]&.size == 1 ? params[:account_id] : params[:account_id]&.compact_blank! )  || session[:account_id]
    end
    session[:vendor_id]   = params[:vendor_id]    || session[:vendor_id]
    session[:category_id] = params[:category_id]  || session[:category_id]

    @trxes = Trx.includes(:vendor,:category, :account, :lines).registerItems
      if (params[:trxes])
        case params[:trxes]
        when "expense"
          @trxes = @trxes.where.not(categories: Category.income).or(Trx.where(lines: Line.where.not(categories: Category.income )))
        when "income"
          @trxes = @trxes.where(categories: Category.income).or(Trx.where(lines: Line.where(categories: Category.income )))
        else
          @trxes
        end
      end
      #ERROR: trxes view, filtering by category "Split", displays Budget trxes, instead of only just registers trxes with split 
      @trxes = @trxes.category_id(params[:category_id].split(',')) if params[:category_id]

      @trxes = @trxes.period(Date.parse(params[:period])) if params[:period]
      # @trxes = @trxes.date(params[:date].to_date) if params[:date]
      @trxes = @trxes.period(Date.parse(params[:period_start]+"-01"),Date.parse(params[:period_end]+"-01")) if params[:period_start] && params[:period_end]

      if (params[:budget])
        case params[:budget]
        when "on"
          @trxes = @trxes.on_budget_accounts.open_accounts
        when "off"
          @trxes = @trxes.off_budget_accounts.open_accounts
        when "closed"
          @trxes = @trxes.closed_accounts
        else
          @trxes
        end
      end
      
      @trxes = @trxes.account(params[:account])         if params[:account]
      #@trxes = @trxes.account_id(params[:account_id].split(',')) if params[:account_id]
      @trxes = @trxes.account_id(session[:account_id].split(',')) if session[:account_id]
      #@trxes = @trxes.vendor(params[:vendor])           if params[:vendor]
      @trxes = @trxes.vendor_id(session[:vendor_id])     if session[:vendor_id]
      #@trxes = @trxes.vendor_id(params[:vendor_id])     if params[:vendor_id]
      @trxes = @trxes.category(session[:category])       if session[:category]
      #@trxes = @trxes.category(params[:category])       if params[:category]
      @trxes = @trxes.parent_id(params[:parent_id])     if params[:parent_id]
      @trxes = @trxes.order('date DESC, id DESC')
      #@trxes = @trxes.order(:id)
  end

  def sort
    @trxes = Trx.includes(:vendor,:category,:account,:lines)
                .registerItems
    if params[:column]
      @trxes = @trxes.order("#{params[:column]} #{params[:direction]}")
    end
    render :index
  end

  def clear_filters
    session[:account_id]  = nil
    session[:vendor_id]   = nil
    session[:category_id] = nil
    redirect_to trxes_path
  end

  #def show; trx end
  #def edit; trx end

  private

  def new_trx_params
    params.fetch(:trx, {}).permit(:id, :date, :memo, :amount, :category_id, :account_id, :vendor_id, :trxes, :cleared,
                                    lines_attributes:[:id, :memo,:amount, :category_id, :_destroy])
    end

  def trx attributes = {}
    @trx ||= begin
      model = params[:id] ? Trx.find(params[:id]) : Trx.new
      model.attributes = attributes
      model
    end
  end

end
