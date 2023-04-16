class VendorsController < ApplicationController
  
  def new
    @vendor = Vendor.new
  end

  def create
    @vendor = Vendor.new(vendor_params)

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to vendors_path }
        format.json { render json: @vendor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @vendor = Vendor.find(params[:id])
  end

  def update
    @vendor = Vendor.find(params[:id])
    if @vendor.update(vendor_params)
      redirect_to vendors_path
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @vendor = Vendor.find(params[:id])
    @vendor.destroy
    redirect_to vendors_path, status: :see_other
  end
  
  def index
    @vendors = Vendor.all
  end

  private

  def vendor_params
    params.require(:vendor).permit(:name)
  end

end
