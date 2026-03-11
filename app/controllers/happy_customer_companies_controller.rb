
class HappyCustomerCompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @search = params.fetch(:search, {}).permit(:company_name)
    @name = @search[:company_name].to_s.strip

    @companies = HappyCustomerCompany.active.order(:company_name)
    if @name.present?
      @companies = @companies.where("company_name ILIKE ?", "%#{@name}%")
    end

    @companies = @companies
      .left_joins(:happy_customers)
      .select("happy_customer_companies.*, COUNT(happy_customers.id) AS customers_count")
      .group("happy_customer_companies.id")

    @companies = @companies.page(params[:page])
  end

  def show
  @customer_search = params.fetch(:search, {}).permit(:q)
  q = @customer_search[:q].to_s.strip

  @customers = @happy_customer_company.happy_customers.order("customer_name ASC")
  if q.present?
    @customers = @customers.where(
      "customer_name ILIKE :q OR email ILIKE :q OR business_phone ILIKE :q",
      q: "%#{q}%"
    )
  end

  @customers = @customers.page(params[:page])
end

  def new
    @happy_customer_company = HappyCustomerCompany.new
  end

  def create
  @happy_customer_company = HappyCustomerCompany.new(company_params)

  @happy_customer_company.user_id = current_user.id
  @happy_customer_company.user_id_update = current_user.id
  begin
    if @happy_customer_company.save
      redirect_to @happy_customer_company, notice: "Company created."
    else
      flash.now[:alert] = "Company not saved!"
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @happy_customer_company.errors.add(:company_name, "already exists (normalized duplicate). Search and use the existing company.")
    flash.now[:alert] = "Company not saved!"
    render :new, status: :unprocessable_entity
  end
end


  def edit; end

  def update
    @happy_customer_company.user_id_update = current_user.id
    if @happy_customer_company.update(company_params)
      redirect_to @happy_customer_company, notice: "Company updated."
    else
      flash.now[:alert] = "Company not updated!"
      render :edit
    end
  end

  def destroy
    @happy_customer_company.destroy
    redirect_to happy_customer_companies_path, notice: "Company deleted."
  end

  private

  def set_company
    @happy_customer_company = HappyCustomerCompany.find(params[:id])
  end

  def company_params
    params.require(:happy_customer_company).permit!
  end
end

