class HappyQuotesController < ApplicationController
before_action :find_quote, only: [:show, :edit, :update, :destroy]
skip_before_action :find_quote, only: [:start, :start_create]

include Reminder

  def index

  @search = params.fetch(:search, {}).permit(:number, :customer_name, :cust_id)
  @search_number = @search[:number].presence

  if @search_number
    @happyquote = HappyQuote.find_by(number: @search_number)

    if @happyquote.nil?
      flash.now[:alert] = "Quote #{@search_number} not found!"
      @search_number = nil   # clears the input after invalid search
    else
      @cust_id = @happyquote.happy_customer_id
      @happyquote = HappyQuote.where(
      #  happy_customer_id: @cust_id,
        number: @search_number 
      ).order(:number)
    end

    else

    if not current_user.admin? and !@search.present?
        @happyquote = HappyQuote.where("happy_customer_id = ? and user_id = ?", params[:customer_id], current_user.id).order("number desc, sub asc")
     else
        @happyquote = HappyQuote.where("happy_customer_id = ?", params[:customer_id]).order("number desc, sub asc")
     end

     respond_to do |format|
      format.html
      format.json { render json: { happyproduct: @happyproduct } }
    end
  end

  end

  def new
    puts "got in new"       
     @happyquote = HappyQuote.new
     @happyvendors = HappyVendor.all.order("vendor_name asc")
     @happycustomer = HappyCustomer.find(params[:happy_customer_id])
     @happycustomer_company = HappyCustomerCompany.find(@happycustomer.happy_customer_company_id)
     @address_type = check_address_type
     if params[:shipaddress_same_billaddress]
          @happyquote.shipping_street1 = @happycustomer.mailing_street1
          @happyquote.shipping_street2 = @happycustomer.mailing_street2
          @happyquote.shipping_city = @happycustomer.mailing_city
          @happyquote.shipping_state = @happycustomer.mailing_state
          @happyquote.shipping_zipcode = @happycustomer.mailing_zipcode
     end
     #this is a global variable and was dangerous customers got mixed up
     #$cust_id = @happycustomer.id
  end

  def show

     #helpers.set_model_name
     loadReminder
     #@model_name = controller_name.classify 
     #@happyReminder = HappyReminder.new
     #@happyReminders = HappyReminder.where("remindable_id = ? and remindable_type = ? and user_id = ? and reminder_date >= ?", params[:id], @model_name, current_user.id, Date.today)

     #@happyNotes = HappyNote.where("noteable_id = ? and noteable_type = ?", '1047', 'HappyQuote')
     @quotetotal = HappyQuoteLine.where("happy_quote_id =?",params[:id]).sum('total_line_amount')
     @quoteTaxTotal = HappyQuoteLine.where("happy_quote_id =? and taxable = ?",params[:id],true).sum('total_line_amount')
       @happycustomer=HappyCustomer.find(@happyquote.happy_customer_id)
       @lines = @happyquote.happy_quote_lines
       @pwfreight = HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id = ?",params[:id],'2').count('happy_vendor_id')

       puts "freight"
       puts @pwfreight
       puts "user id"
       puts @happyquote.user_id_add

     discount_tax_calc

     #if @happyquote.user_id_add.present?
       #@happyquote.user_id_add = 1
     #end

     if @happyquote.user_id_add
        @userAdd = User.find(@happyquote.user_id_add)
        #@userAdd = User.find(current_user.id)
        puts "userAdd"
        puts @userAdd.username
       end
       if @happyquote.user_id_update
        @userUpdate = User.find(@happyquote.user_id_update)
        #@userUpdate = User.find(current_user.id)
       end

    @happyquotevendors=HappyQuoteLine.joins(:happy_vendor).where("happy_quote_id =?",params[:happy_quote_id]).distinct.select('happy_vendor_id','happy_vendors.vendor_name', 'first_name') 
    @happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).order("happy_quote_lines.position asc").find(params[:id])
    @happycustomer_company = HappyCustomerCompany.find(@happycustomer.happy_customer_company_id)
    @address_type = check_address_type

     @happyquote.update_column(:total, @quotetotal)

     respond_to do |format|
      format.html
      format.pdf 
    end
  end


  def simple
     respond_to do |format|
      format.html
      format.pdf 
    end
  end

  def edit
    #@happyquotevendors=HappyQuoteLine.joins(:happy_vendor).where("happy_quote_id =?",params[:happy_quote_id]).distinct.select('happy_vendor_id','happy_vendors.vendor_name', 'first_name') 
     @happyvendors = HappyVendor.select('vendor_name','id').order("vendor_name asc")
     #@happyvendors = HappyVendor.all.order("vendor_name asc")
     #@happycustomer = HappyCustomer.find(@happyquote.happy_customer_id)
     #@filename = "happy_quote.pdf"
     @balance = 0
     @quotetotal = @balance + HappyQuoteLine.where("happy_quote_id =?",params[:id]).sum('total_line_amount')
     #@quotetotal = @balance + HappyQuoteLine.sum('total_line_amount').where("happy_quote_id =?",params[:id])
     #@happyquote = HappyQuote.where("happy_customer_id = ?", params[:customer_id])
    @happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).order("happy_quote_lines.position asc").find(params[:id])
     puts "******below happyquote ******"
     # ✅ mark as sent only when PDF is generated
     Rails.logger.info "FORMAT=#{request.format}"
     Rails.logger.info "PARAMS_FORMAT=#{params[:format].inspect}"

     if params[:format] == "pdf" && (@happyquote.status.blank? || @happyquote.status == "open")
       @happyquote.update_column(:status, "sent")
     end
     puts @happyquote.happy_customer_id
     @happycustomer = HappyCustomer.find(@happyquote.happy_customer_id)
     @happycustomer_company = HappyCustomerCompany.find(@happycustomer.happy_customer_company_id)
     @address_type = check_address_type
     @useremail = current_user.email
     @quoteTaxTotal = HappyQuoteLine.where("happy_quote_id =? and taxable = ?",params[:id],true).sum('total_line_amount')
     if params[:product_id]
        @happyproduct = HappyProduct.find(params[:product_id])
     end 
     respond_to do |format|
      format.html
      format.pdf
      format.json { render json: { happyproduct: @happyproduct } }
    end

    discount_tax_calc

  end

  #def get_product
   #respond_to do |format|    
      #format.html              
      #format.json { render json: { happyproduct: @happyproduct } } 
    #end
    #puts "here above product"       
   #if params[:productid]
        #@happyproduct = HappyProduct.where("part_number = ?" ,params[:productid])
        ##puts @happyproduct
     #end
  #end

  def create
    #Rails.logger.debug happyquote_params.inspect
    #Rails.logger.debug @happycustomer.inspect

    @happycustomer = HappyCustomer.find(happyquote_params[:happy_customer_id])
    @user = current_user
    
    #@happyquote = @happycustomer.happy_quotes.new(happyquote_params)
    #@happyquote = current_user.happy_customers.happy_quotes.new(happyquote_params)
    # works with happy_customer has many commented out @happyquote = current_user.happy_quotes.new(happyquote_params)
     @happyquote = @happycustomer.happy_quotes.new(happyquote_params)
     @happyquote.user_id = @user.id
     @happyquote.user_id_add = @user.id
    # below works but gives database error look at hidden form fields
     #@happyquote.user=(current_user)
     #@happyquote = @happycustomer.happy_quotes.new(happyquote_params,current_user)
    if @happyquote.save
      flash[:success] = "Quote saved!"
      redirect_to @happyquote
    else
      flash[:alert] = "Quote not saved!"
      # This line overrides the default rendering behavior, which
      # would have been to render the "create" view.
      # I had to add below to get vendor select box to work after validation fails
      # render new needs to be there but not sure why below does not execute in new method
      @happyvendors = HappyVendor.all.order("vendor_name asc")
      render :new
    end
  end

  def update
      puts happyquote_params[:fob]
    params[:happy_quote][:happy_quote_lines_attributes].each do |line_number, params|
      puts "here"
      puts line_number
      puts params[:total_line_amount]
      params[:total_line_amount] = params[:total_line_amount].gsub(/[\s,]/ ,"")
     @happyquote.user_id_update = current_user.id
    end
    if @happyquote.update(happyquote_params)
       @happyquote.save
      redirect_to @happyquote
    else
      @happycustomer = HappyCustomer.find(happyquote_params[:happy_customer_id])
      @happyvendors = HappyVendor.select('vendor_name','id').order("vendor_name asc")
      render 'edit'
      #render :action => 'edit'
    end
  end

  def remove_commas(num)
    #newnum = (num.replace(/,/g, ''))
    return newnum
  end

  def destroy
    @happyquote.destroy
    redirect_to action: "index"
  end

  def copy
    @happyquote = HappyQuote.includes(:happy_quote_lines).order("happy_quote_lines.position asc").find(params[:happy_quote_id])
    @happyquoteclone = @happyquote.clone   # works for line items
    @happyquotedup = @happyquote.dup   # works for header
    puts "@happyquote number", @happyquote.number
    puts "@happyquoteclone number", @happyquoteclone.number
    puts "@happyquote", @happyquote
    puts "@happyquoteclone", @happyquoteclone
    #@happyquoteclone.sub = @happyquoteclone.sub + 1 

    # Update sub for new header
      @newsub = HappyQuote.where(number: @happyquote.number).count 
      #@happyquotedup.copy = true
     
    # Don't Update original

    # Get id of last header so you can put on details happy_quote_id
    #
    

    @happyquotedup.sub = @newsub
    @happyquotedup.order_date = ''
      #@happyquotedup.copy = true
    @happyquotedup.save
    @newid = @happyquotedup.id

      #@headerid=HappyQuote.connection.execute("SELECT currval('happy_quotes_id_seq'::regclass)")

    linePosition = 1

    @happyquoteclone.happy_quote_lines.each { |line|
          @newline = line.dup
          @newline.happy_quote_id = @newid
          @newline.position = linePosition
          #@newline.number = @happyquotedup.number
          #@newline.sub = @happyquotedup.sub
          puts "newline", @newline
          puts "newid", @newid
          puts "in line loop"
          puts line.id
          puts line.product_id
          @newline.save
          linePosition += 1
    }

    flash.notice = "Quote: #{@happyquoteclone.number}-#{@newsub} created." 
    redirect_to action: 'edit', id: @newid
  end


  def createsub
    @happyquote=HappyQuote.find(params[:happy_quote_id])
    @happyquote.number = params[:happy_quote_id]
    @happyquote.sub = @happyquote.sub + 1
    HappyQuote.create    
    #@happyquotelines=HappyQuoteLines.find(params[:happy_quote_id]) do |line|
    #end

    puts "got in createsub"       
  end

  def po
    puts "Po test"
    puts params[:happy_customer_id]

    quote_id = params[:happy_quote_id] || params[:id]
    @happyquote=HappyQuote.find(quote_id)

    #@happyproject=HappyProject.where("happy_quote_id = ?", params[:happy_quote_id])
    #@happyproject=HappyProject.find_by("id = ?", 1)

    customer_id = params[:happy_customer_id].presence || @happyquote.happy_customer_id
    @happycustomer = HappyCustomer.find(customer_id)

    @happyproject=HappyProject.find_by("happy_quote_id = ?", quote_id)

    @numberLocations=HappyInstallSite.where("happy_customer_id = ?", customer_id).count

    # works @happyquotevendors=HappyQuoteLine.joins(:happy_vendor).where("happy_quote_id =?",params[:happy_quote_id]).distinct.select('happy_vendor_id','happy_vendors.vendor_name', 'first_name') 
    
    @happyquotevendors=HappyQuoteLine.joins(:happy_vendor).where('happy_quote_lines.happy_quote_id = ?', quote_id).group('happy_quote_lines.happy_vendor_id', 'happy_vendors.vendor_name').select('happy_quote_lines.happy_vendor_id, happy_vendors.vendor_name, sum(total_line_amount) as total, sum(total_cost_amount) as cost')

    #@happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).where("happy_vendor_id =?", params[:vendor_id]).order("happy_quote_lines.position asc").find(params[:happy_quote_id])
    #@happyquote=HappyQuote.find(params[:happy_quote_id])

    puts "Po test1"
    @happyPo=HappyPo.where("happy_quote_id =?", params[:happy_quote_id])
    #@happyPo=HappyPo.where("happy_quote_id = ?",params[:happy_quote_id])
    puts "Po test2"
    #@happyPo=HappyPo.where("number = ? and sub = ?", @happyquote.number, @happyquote.sub)
    #@happyquote=HappyQuote.find(params[:happy_quote_id])
    #@happyquotevendors=HappyQuoteLine.where("happy_quote_id =?",params[:happy_quote_id]).distinct.select('happy_vendor_id') 
    #@quotetotal = @balance + HappyQuoteLine.where("happy_quote_id =?",params[:id]).sum('total_line_amount')
  end

  def pwfreight
     @taxAmount = 0
     @discountAmount = 0
     @quotetotal = 0
     @vendor_id = 2
     #if !@happyquote 
     #    @happyquote = HappyQuote.new
     #end 
     params.each do |key,value|
       Rails.logger.warn "Param #{key}: #{value}"
     end
     @submit = params["submit"]
     if @submit.present?
        @type_of_business = @submit["customer_type"]
     end
     #puts params[:submit].customer_type
     #@type_of_business = @happyquote.customer_type
     #@type_of_business = @happy.customer_type
     #@type_of_business = "test"
     respond_to do |format|
      format.html
      format.pdf
    end
     @useremail = current_user.email
     @username = current_user.username
     @happyvendor = HappyVendor.find(@vendor_id)
     #@filename = "happy_quote.pdf"
     @balance = 0
     #@discountAmount = HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_quote_id], params[:vendor_id]).sum('sell_discount')
     #@pototal = @balance + HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_quote_id], params[:vendor_id]).sum('total_cost_amount')
    #@happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).where("happy_vendor_id =?", params[:vendor_id]).order("happy_quote_lines.position asc").find(params[:happy_quote_id])
    @happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).where("happy_vendor_id =? and weight != ?", @vendor_id, 0).order("happy_quote_lines.position asc").find(params[:happy_quote_id])
     #@happyquote.update_attribute(:order_date, Date.today)
     @lines = @happyquote.happy_quote_lines
     if params[:product_id]
        @happyproduct = HappyProduct.find(params[:product_id])
     end 
  end

  def pocreate
     @taxAmount = 0
     @discountAmount = 0
     @quotetotal = 0
     respond_to do |format|
      format.html
      format.pdf
    end
     @useremail = current_user.email
     @happyvendor = HappyVendor.find(params[:vendor_id])
     #@filename = "happy_quote.pdf"
     @balance = 0
     @discountAmount = HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_quote_id], params[:vendor_id]).sum('sell_discount')
     @pototal = @balance + HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_quote_id], params[:vendor_id]).sum('total_cost_amount')
     #@quotetotal = @balance + HappyQuoteLine.sum('total_line_amount').where("happy_quote_id =?",params[:id])
     #@happyquote = HappyQuote.where("happy_customer_id = ?", params[:customer_id])
     @happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).where("happy_vendor_id =?", params[:vendor_id]).order("happy_quote_lines.position asc").find(params[:happy_quote_id])
     
     # Added status per chatgpt
     #
     #unless %w[won lost].include?(@happyquote.status)
     #   @happyquote.update_column(:status, "won")
     #   Rails.logger.info "Marked quote #{@happyquote.id} WON via PO finalize"
     #end


     if @happyquote.order_date.nil? 
       @happyquote.update_attribute(:order_date, Date.today)
     end

     if params[:status] == "final" && @happyquote.order_date.nil?
        @happyquote.update_column(:order_date, Date.current)
     end

       insertPo = request.format
       puts "insertPo"
       puts insertPo
     @lines = @happyquote.happy_quote_lines
     if params[:product_id]
        @happyproduct = HappyProduct.find(params[:product_id])
     end 
  end

  def calculate_sales_tax
      origin = TaxCloud::Address.new(
             :address1 => '162 East Avenue',
             :address2 => 'Third Floor',
             :city => 'Norwalk',
             :state => 'CT',
             :zip5 => '06851')
      destination = TaxCloud::Address.new(
             :address1 => '3121 West Government Way',
             :address2 => 'Suite 2B',
             :city => 'Seattle',
             :state => 'WA',
             :zip5 => '98199')

   transaction = TaxCloud::Transaction.new(
             :customer_id => '1',
             :cart_id => '1',
             :origin => origin,
             :destination => destination)
      transaction.cart_items << TaxCloud::CartItem.new(
             :index => 0,
             :item_id => 'SKU-100',
             :tic => TaxCloud::TaxCodes::GENERAL,
             :price => 10.00,
             :quantity => 1)

      lookup = transaction.lookup # this will return a TaxCloud::Responses::Lookup instance
      lookup.tax_amount # total tax amount
      #lookup.cart_items.each do |cart_item|
      #     cart_item.tax_amount # tax for a single item
      #end
     puts lookup.tax_amount
   end

    def sortlines
     #params.each do |key,value|
     #   Rails.logger.warn "Param #{key}: #{value}"
     #end
       #Did not work for lineitems @happyquote=HappyQuote.where("id =?",params[:happy_quote_id])
       # ** this works @happyquote=HappyQuote.find 1019
       @happyquote=HappyQuote.find(params[:id])
       @happycustomer=HappyCustomer.find(@happyquote.happy_customer_id)
       @lines = @happyquote.happy_quote_lines
    end

    def move
     params.each do |key,value|
       Rails.logger.warn "Param #{key}: #{value}"
     end
     puts "got in move" 
      # ** this works @happyquoteline=HappyQuoteLine.find 123
      #@happyquoteline=HappyQuoteLine.find 123
      #below works but happy_quote_id's value is happy_quote_lines.id 
      @happyquoteline=HappyQuoteLine.find(params[:happy_quote_id]) 
      #@happyquoteline=HappyQuoteLine.where("id =?",params[:happy_quote_id])
      @happyquoteline.insert_at(params[:position].to_i)
    head :ok
  end

      # PATCH /happy_quotes/:id/set_status?status=pending|lost|won|open|sent|draft
  def set_status
    @happyquote = HappyQuote.find(params[:id])

    new_status = params[:status].to_s.downcase

    allowed = %w[draft open sent pending won lost]
    unless allowed.include?(new_status)
      redirect_to @happyquote, alert: "Invalid status" and return
    end

    # prevent humans from overwriting finalized quotes
    if %w[won lost].include?(@happyquote.status) && new_status != @happyquote.status
      redirect_to @happyquote, alert: "Quote already finalized as #{@happyquote.status}." and return
    end

    @happyquote.update!(
      status: new_status,
      user_id_update: current_user.id
    )

    redirect_to @happyquote, notice: "Marked quote #{new_status.upcase}."
  end


def start
  @company_id = params[:happy_customer_company_id].presence
  @companies  = HappyCustomerCompany.order(:company_name)

  @customers = @company_id ? HappyCustomer.where(happy_customer_company_id: @company_id).order(:customer_name) : []
end

def start_create
  customer_id = params[:happy_customer_id].presence

  if customer_id.blank?
    redirect_to start_happy_quotes_path(happy_customer_company_id: params[:happy_customer_company_id]),
                alert: "Please select a customer."
    return
  end

  redirect_to new_happy_quote_path(happy_customer_id: customer_id)
end

private

  def check_address_type
    companyAddress = [@happycustomer_company.customer_street1, @happycustomer_company.customer_street2,
     @happycustomer_company.customer_city, @happycustomer_company.customer_state, @happycustomer_company.customer_zipcode ]
    customerAddress = [@happycustomer.mailing_street1, @happycustomer.mailing_street2, @happycustomer.mailing_city,
      @happycustomer.mailing_state, @happycustomer.mailing_zipcode]
    quoteAddress = [@happyquote.mailing_street1, @happyquote.mailing_street2, @happyquote.mailing_city,
      @happyquote.mailing_state, @happyquote.mailing_zipcode]
    if quoteAddress == customerAddress
      "Customer Address"
    elsif quoteAddress == companyAddress
      "Company Address"
    else
      nil
    end
  end

  def find_quote
    @happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).order("happy_quote_lines.position asc").find(params[:id])
  end

  def set_s3_object
    s3 = Aws::S3::Resource.new(region: ENV.fetch("AWS_REGION"),
        access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
        secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"))
    bucket_name = ENV.fetch("AWS_BUCKET_NAME")
    @key = "hello_world.pdf"
    @s3_obj = s3.bucket(bucket_name).object(@key)
  end

  def happyquote_params
    params.require(:happy_quote).permit(
   :happy_customer_id, :terms, :fob, :quote_date, :estimated_delivery_date,
   :email, :customer_id, :customer_name, :shipaddress_same_billaddress,
   :shipping_street1, :shipping_street2, :shipping_city, :shipping_state, :shipping_zipcode,
   :mailing_street1, :mailing_street2, :mailing_city, :mailing_state, :mailing_zipcode,
   :special_instructions, :internal_notes, :external_notes,:user_id,
   :tax_override, :tax_rate, :additional_tax_total,:discount_override,
   :discount_total, :user_name, :included_tax_total,
    happy_quote_lines_attributes: [:id, :product_id,
     :description,
     :color,
     :quantity,
     :unit_of_measure,
     :weight,
     :purchase_discount,
     :unit_price,
     :total_line_amount,
     :taxable,
     :tax_amount,
     :happy_vendor_id,
     :vendor_name,
     :buyout_unit_price,
     :margin,
     :total_cost_amount,
     :sell_discount,
     :quote_subtotal,
     :quote_margin,
     :cost_override,
     :external_notes,
     :internal_notes,
     :active,
     :_destroy]
)
  end
#Unpermitted parameters: :quote_subtotal, :total_cost_amount, :quote_margin
#Unpermitted parameters: :special_instructions, :internal_notes, :external_notes

  def happyquotenew_params
    params.permit( :happy_customer_id )
  end

  def discount_tax_calc
    #ZipTax.key="gWiqheMSO7RUQ6Gm"
    if @happyquote.discount_override then
          @discountAmount = @happyquote.discount_total
    else
          @discountAmount = 0
    end

    if @happyquote.happy_customer.taxable then
      if @happyquote.tax_override and @happyquote.additional_tax_total? then
                @taxAmount = @happyquote.additional_tax_total
      else
          #begin
          #       @taxRate=ZipTax.rate(@happyquote.shipping_zipcode)
          #       puts @quoteTaxTotal
          #       puts @taxRate
          #       @taxAmount = @quoteTaxTotal * @taxRate
          #rescue
          #end
          @taxAmount = 0
      end
      else
        @taxAmount = 0
      end
    end # discount_tax_calc end
end
