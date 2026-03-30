class HappyCategoriesController < ApplicationController

  def index
    @happy_categories = HappyCategory.order(:happy_vendor_id, :category).page params[:page]
    @search = params["search"]
    if @search.present?
      @name = @search["category"]
      @happy_categories = HappyCategory.where("category ILIKE ?", "%#{@name}%").order("category DESC").page(params[:page])
    end
  end

  def show
    @happy_category = HappyCategory.find(params[:id])
    @happy_products = HappyProduct.where("happy_category_id=?", params[:id]).page params[:page]
    @search = params["search"]
    if @search.present?
      @part = @search["part_number_or_description"]
      @happy_products = HappyProduct.where("happy_category_id=? and (description ILIKE ? OR part_number ILIKE ?)", params[:id], "%#{@part}%", "%#{@part}%").order("happy_category_id").page(params[:page])
    end
  end

  def new
    @happy_category = HappyCategory.new
    @vendors = HappyVendor.order(:vendor_name)
  end

  def create
    @happy_category = HappyCategory.new(happy_category_params)
    @happy_category.user_id = current_user.id
    @happy_category.user_id_update = current_user.id
    @happy_category.happy_profit_center_id = 1
    begin
    if @happy_category.save
      flash[:success] = "Product Category Saved!"
      redirect_to @happy_category
    else
      flash.now[:alert] = "Category not saved!"
      render :new, status: :unprocessable_entity
    end
    rescue ActiveRecord::RecordNotUnique
      @happy_category.errors.add(:category, "already exists")
      flash.now[:alert] = "Category not saved!"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @happy_category = HappyCategory.find(params[:id])
    @vendors = HappyVendor.order(:vendor_name)
  end

  def update
    @happy_category = HappyCategory.find(params[:id])
    @happy_category.user_id_update = current_user.id
    if @happy_category.update(happy_category_params)
      flash[:success] = "Happy Category was successfully updated"
      redirect_to @happy_category
    else
      render :action => 'edit'
    end
  end

  def destroy
    @happy_category.destroy
    redirect_to action: "index"
  end

  private
  def happy_category_params
    params.require(:happy_category).permit!
  end

end
