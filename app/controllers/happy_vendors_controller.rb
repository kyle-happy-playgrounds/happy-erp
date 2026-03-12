class HappyVendorsController < ApplicationController
  before_action :find_vendor, only: [:show, :edit, :update, :destroy]

  def index
    @vendors = HappyVendor.order("vendor_name ASC").page params[:page]
    @search = params["search"]
    if @search.present?
      @name = @search["vendor_name"]
      @vendors = HappyVendor.where("vendor_name ILIKE ?", "%#{@name}%").order("vendor_name DESC").page(params[:page])
    end
  end

  def new
    @happyvendor = HappyVendor.new
  end

  def show
     @model_name = controller_name.classify
     @happyReminder = HappyReminder.new
     @happyReminders = HappyReminder.where("remindable_id = ? and remindable_type = ? and user_id = ? and reminder_date >= ?", params[:id], @model_name, current_user.id, Date.today)
    #@happypos = HappyQuoteLine.where("happy_vendor_id = ?", params[:id]).order("number DESC")
    #@happypos = HappyQuote.select (number as number'sum(where("happy_vendor_id = ?", params[:id]).order("number DESC")
    #@happypos = HappyQuote.includes(:happy_quote_lines).includes(:happy_vendors).select("happy_quote_lines.happy_vendor_id as vendor, happy_quotes.number AS number, happy_vendors.vendor_name as vendor_name, happy_quotes.special_instructions as special_instructions,  avg(purchase_discount) as purchase_discount, sum(total_cost_amount) AS po_amount FROM happy_quotes INNER JOIN happy_quote_lines ON happy_quotes.id = happy_quote_lines.happy_quote_id INNER JOIN happy_vendors ON happy_quote_lines.happy_vendor_id = happy_vendors.id").group("happy_vendor_id,happy_quotes.number,happy_vendors.vendor_name,happy_quotes.special_instructions").where("happy_vendor_id = ?", params[:id]).order("number DESC")
    #@happypos = HappyQuote.includes(:happy_quote_lines).includes(:happy_vendors).select("happy_quotes.number AS number, happy_vendors.happy_vendor_id as happy_vendor_id").where("happy_vendor_id = ?", params[:id]).order("number DESC")
    @happypos = HappyQuote.joins("INNER JOIN happy_quote_lines ON happy_quotes.id = happy_quote_lines.happy_quote_id INNER JOIN happy_vendors ON happy_quote_lines.happy_vendor_id = happy_vendors.id").select("happy_quote_lines.happy_vendor_id as happy_vendor_id, happy_quotes.number AS number, happy_quotes.order_date as order_date, happy_quotes.special_instructions as special_instructions,  avg(purchase_discount) as purchase_discount, sum(total_cost_amount) AS po_amount").group("happy_vendor_id,happy_quotes.number,happy_quotes.order_date,happy_quotes.special_instructions").where("happy_vendor_id = ?", params[:id]).order("number DESC")
  end

  def edit
  end

  def update
    @happyvendor.user_id_update = current_user.id
    if @happyvendor.update(happyvendor_params)
      flash[:success] = "Happy Vendor was successfully updated"
      redirect_to @happyvendor
    else
      render :action => 'edit'
    end
  end

  def create
    @happyvendor = HappyVendor.new(happyvendor_params)
    @happyvendor.user_id = current_user.id
    @happyvendor.user_id_update = current_user.id
    if @happyvendor.save
      flash[:success] = "Vendor saved!"
      redirect_to @happyvendor
    else
      flash[:alert] = "Vendor not saved!"
      # This line overrides the default rendering behavior, which
      # would have been to render the "create" view.
      render "new"
    end
  end

  def destroy
    @happyvendor.destroy
    redirect_to action: "index"
  end

private 

  def happyvendor_params
     params.require(:happy_vendor).permit!
  end

  def find_vendor
    @happyvendor = HappyVendor.find(params[:id])
  end

end
