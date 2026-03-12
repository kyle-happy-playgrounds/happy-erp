class HappyCustomersController < ApplicationController
  before_action :find_customer, only: [:show, :edit, :update, :destroy]

  attr_accessor :cust_name

  def index
  @search = params.fetch(:search, {}).permit(:cust_name)
  @name = @search[:cust_name].to_s.strip

  @customers = HappyCustomer.order("customer_name ASC")

  if @name.present?
    @customers = @customers.where("customer_name ILIKE ?", "%#{@name}%")
  end

  @customers = @customers
    .left_joins(:happy_install_sites)
    .select("happy_customers.*, COUNT(happy_install_sites.id) AS happy_installs_count")
    .group("happy_customers.id")
    .page(params[:page])
end

  def new
    @happycustomer = HappyCustomer.new
    if params[:happy_customer].present?
    @happycustomer.assign_attributes(params.require(:happy_customer).permit(:happy_customer_company_id))
  end
  end

  def show
     if not current_user.admin? and !@search.present?
        @happyquotes = HappyQuote.where("happy_customer_id = ? and user_id = ?", params[:id], current_user.id).order("number desc, sub desc")
     else
        @happyquotes = HappyQuote.where("happy_customer_id = ?", params[:id]).order("number desc, sub desc")
     end
    @@happyquotes = HappyQuote.where("happy_customer_id = ?", params[:id]).order("number DESC, sub DESC")
    @quotetotal = HappyQuoteLine.where("happy_quote_id =?",params[:id]).sum('total_line_amount')
    @model_name = controller_name.classify
    @happyReminder = HappyReminder.new
    @happyReminders = HappyReminder.where("remindable_id = ? and remindable_type = ? and user_id = ? and reminder_date >= ?", params[:id], @model_name, current_user.id, Date.today)
  end

  def edit
  end

  def update
    #authorize @happycustomer
    @happycustomer.user_id_update = current_user.id
    if @happycustomer.update(happycustomer_params)
      flash[:success] = "Happy Customer Contact was successfully updated"
      redirect_to @happycustomer
    else
      render :action => 'edit'
    end
  end

def create
  @happycustomer = HappyCustomer.new(happycustomer_params)
  @happycustomer.user_id = current_user.id
  @happycustomer.user_id_update = current_user.id
  if @happycustomer.save
    flash[:success] = "Customer Contact saved!"
    redirect_to @happycustomer
  else
    flash.now[:alert] = "Customer not saved!"
    render :new, status: :unprocessable_entity
  end
end


  def destroy
    @happycustomer.destroy
    redirect_to action: "index"
  end

private 

  def happycustomer_params
     params.require(:happy_customer).permit!
  end

  def find_customer
    @happycustomer = HappyCustomer.find(params[:id])
  end

end
