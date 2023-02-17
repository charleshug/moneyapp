class CategoriesController < ApplicationController

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      redirect_to categories_path
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to categories_path, status: :see_other
  end

  def index
    @categories = Category.includes(:parent).all
  end

  def show
    @category = Category.find(params[:id])    
  end

  def categories_data
    #TODO: Add date_filter capability
    #params[:date_filter] ? @date_filter = Date.parse(params[:date_filter] + "-01") : @date_filter = Date.today.beginning_of_month
    
    @category_filter = params[:category_filter]
    @categories = Category.where(parents: Category.find_by(name: @category_filter))
    @categories = @categories.joins(:trxes)
                             .merge(Trx.registerItems
                                        .nonIncome
                                        #add date filter here
                            )
                             .group(:name)
                             .sum(:amount)
                             .sort_by { |k,v| v }
                             .map { |x,y| { x => (y/100.0).round(2) } }
                             .reduce({}, :merge)
    @categories_total = @categories.map { |k,v| v }.sum
  end

 private
    def category_params
      params.require(:category).permit(:name, :parent_id, :hidden, :category_filter)
    end
end
