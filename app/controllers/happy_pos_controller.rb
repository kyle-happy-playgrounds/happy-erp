class HappyPosController < ApplicationController
before_action :find_po, only: [:show, :edit, :update, :destroy]

  def index

    @search = params["search"]
    if @search.present?
      puts "got in index"       
        @number = @search["number"]
      puts @number
      #@happyquote = HappyQuote.where("number = ? and happy_customer_id = ?", @number, 13)
      @happyquote = HappyQuote.find_by_id(@number)
      if !@happyquote.nil?
          @cust_id = @happyquote.happy_customer_id
          @happyquote = HappyQuote.where("happy_customer_id = ? and number = ?", @happyquote.happy_customer_id, @number).order("number asc")
          puts "cust_id"
          puts @cust_id
      else 
          flash.now[:alert] = "Quote #{@number} not found!"
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
     @model_name = controller_name.classify 
     @happyReminder = HappyReminder.new
     @happyReminders = HappyReminder.where("remindable_id = ? and remindable_type = ? and user_id = ? and reminder_date >= ?", params[:id], @model_name, current_user.id, Date.today)

     #@happyNotes = HappyNote.where("noteable_id = ? and noteable_type = ?", '1047', 'HappyQuote')
     @taxAmount = 0
     @discountAmount = 0
     @quotetotal = 0
     @useremail = current_user.email
     #@filename = "happy_quote.pdf"
     @balance = 0
     @discountAmount = HappyPoLine.where("happy_po_id =?", params[:id]).sum('sell_discount')
     @pototal = @balance + HappyPoLine.where("happy_po_id =?", params[:id]).sum('total_line_amount')
     @quotetotal = HappyPoLine.where("happy_po_id =?",params[:id]).sum('total_line_amount')
     @quoteTaxTotal = HappyPoLine.where("happy_po_id =? and taxable = ?",params[:id],true).sum('total_line_amount')
       @happycustomer=HappyCustomer.find(@happypo.happy_customer_id)
       @happyvendor=HappyVendor.find(@happypo.happy_vendor_id)
       @happyquote=HappyQuote.find(@happypo.happy_quote_id)
       @lines = @happypo.happy_po_lines
       #@pwfreight = HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id = ?",params[:id],'2').count('happy_vendor_id')

       puts "freight"
       #puts @pwfreight

     #discount_tax_calc

     #@happyquote.update_column(:total, @quotetotal)

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
     @happyvendors = HappyVendor.select('vendor_name','id').order("vendor_name asc")
     #@happyvendors = HappyVendor.all.order("vendor_name asc")
     #@happycustomer = HappyCustomer.find(@happyquote.happy_customer_id)
     #@filename = "happy_quote.pdf"
     @balance = 0
     @quotetotal = @balance + HappyQuoteLine.where("happy_quote_id =?",params[:id]).sum('total_line_amount')
     #@quotetotal = @balance + HappyQuoteLine.sum('total_line_amount').where("happy_quote_id =?",params[:id])
     #@happyquote = HappyQuote.where("happy_customer_id = ?", params[:customer_id])
    @happypo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).order("happy_po_lines.position asc").find(params[:id])
     puts "******below happyquote ******"
     puts @happypo.happy_customer_id
     @happycustomer = HappyCustomer.find(@happypo.happy_customer_id)
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

    #discount_tax_calc

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
      #puts happyquote_params[:fob]
    params[:happy_po][:happy_po_lines_attributes].each do |line_number, params|
      puts "here"
      puts line_number
      puts params[:total_line_amount]
      params[:total_line_amount] = params[:total_line_amount].gsub(/[\s,]/ ,"")
    end
    if @happypo.update(happypo_params)
       @happypo.save
      redirect_to @happypo
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
    @happyquote = HappyQuote.includes(:happy_quote_lines).order("happy_quote_lines.id asc").find(params[:happy_quote_id])
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

  def po_final
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
     #@happypo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).where("id =?", params[:id]).order("happy_po_lines.position asc").find(params[:happy_quote_id])
     @happypo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).where("id =?", params[:id]).order("happy_po_lines.position asc")
     #if @happyquote.order_date.nil?
     #  @happyquote.update_attribute(:order_date, Date.today)
     #end
       insertPo = request.format
       puts "insertPo"
       puts insertPo
     @lines = @happypo.happy_po_lines
     #if params[:product_id]
     #   @happyproduct = HappyProduct.find(params[:product_id])
     #end
  end


  def po
    puts "Po test"
    puts params[:happy_customer_id]
    #@happyproject=HappyProject.where("happy_quote_id = ?", params[:happy_quote_id])
    #@happyproject=HappyProject.find_by("id = ?", 1)
    @happycustomer = HappyCustomer.find(params[:happy_customer_id])
    @happyproject=HappyProject.find_by("happy_quote_id = ?", params[:happy_quote_id])
    @numberLocations=HappyInstallSite.where("happy_customer_id = ?", params[:happy_customer_id]).count
    @happyquotevendors=HappyQuoteLine.joins(:happy_vendor).where("happy_quote_id =?",params[:happy_quote_id]).distinct.select('happy_vendor_id','happy_vendors.vendor_name', 'first_name') 
    #@happyquotevendors=HappyQuoteLine.where("happy_quote_id =?",params[:happy_quote_id]).distinct.select('happy_vendor_id') 
    #@quotetotal = @balance + HappyQuoteLine.where("happy_quote_id =?",params[:id]).sum('total_line_amount')
  end

  def pwfreight
     @taxAmount = 0
     @discountAmount = 0
     @quotetotal = 0
     @vendor_id = 2
     if !@happyquote 
         @happyquote = HappyQuote.new
     end 
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
    @happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).where("happy_vendor_id =?", @vendor_id).order("happy_quote_lines.position asc").find(params[:happy_quote_id])
     #@happyquote.update_attribute(:order_date, Date.today)
     @lines = @happyquote.happy_quote_lines
     if params[:product_id]
        @happyproduct = HappyProduct.find(params[:product_id])
     end 
  end

  def finalize
     @taxAmount = 0
     @discountAmount = 0
     @quotetotal = 0
     @happypo = HappyPo.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_po_id],params[:vendor_id])
     Rails.logger.debug @happypo.inspect
     if @happypo.present?
       puts "got po"
       params.inspect
       @happyvendor = HappyVendor.find(params[:vendor_id])
       @balance = 0
       @discountAmount = HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_po_id], params[:vendor_id]).sum('sell_discount')
       @pototal = @balance + HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_po_id], params[:vendor_id]).sum('total_cost_amount')
       @happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).where("happy_vendor_id =?", params[:vendor_id]).order("happy_quote_lines.position asc").find(params[:happy_po_id])
       @lines = @happyquote.happy_quote_lines
       puts @happypo
       flash[:notice] = "This Purchase Order has already been finalized."
       redirect_to happy_quote_pocreate_url(params[:happy_po_id], vendor_id: params[:vendor_id], status: 'final')
     else
       puts "no po"
     #@happyPo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).where("happy_vendor_id =?", params[:vendor_id]).order("happy_po_lines.position asc").find(params[:happy_po_id])
     #respond_to do |format|
     # format.html
     # format.pdf
    #end
     @useremail = current_user.email
     @happyvendor = HappyVendor.find(params[:vendor_id])
     #@filename = "happy_quote.pdf"
     @balance = 0
     @discountAmount = HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_quote_id], params[:vendor_id]).sum('sell_discount')
     @pototal = @balance + HappyQuoteLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_quote_id], params[:vendor_id]).sum('total_cost_amount')
     #@quotetotal = @balance + HappyQuoteLine.sum('total_line_amount').where("happy_quote_id =?",params[:id])
     #@happyquote = HappyQuote.where("happy_customer_id = ?", params[:customer_id])
     @happyquote = HappyQuote.includes(:happy_customer).includes(:happy_quote_lines).where("happy_vendor_id =?", params[:vendor_id]).order("happy_quote_lines.position asc").find(params[:happy_po_id])

      # ✅ PO finalized => quote is WON (unless already final)
      if @happyquote.present? && !%w[won lost].include?(@happyquote.status)
        @happyquote.update_columns(
          status: "won",
          state: "PO",                  # optional, keep your business label
          order_date: Date.current,
          user_id_update: current_user.id
        )
        Rails.logger.info "Marked quote #{@happyquote.id} WON via PO finalize"
      end


       insertPo = request.format
       puts "insertPo"
       puts insertPo
     @lines = @happyquote.happy_quote_lines
     if params[:product_id]
        @happyproduct = HappyProduct.find(params[:product_id])
     end 

     happyPo = HappyPo.new(happy_company_id: @happyquote.happy_company_id,
                            happy_profit_center_id: @happyquote.happy_profit_center_id,
                            happy_customer_id: @happyquote.happy_customer_id,
                            happy_vendor_id: @happyvendor.id,
                            happy_quote_id: @happyquote.id,
                            number: @happyquote.number,
                            sub: @happyquote.sub,
                            record_type: @happyquote.record_type,
                            quote_date: @happyquote.quote_date,
                            order_date: @happyquote.order_date,
                            shipping_method: @happyquote.shipping_method,
                            fob: @happyquote.fob,
                            terms: @happyquote.terms,
                            requested_ship_date: @happyquote.estimated_ship_date,
                            estimated_delivery_date: @happyquote.estimated_delivery_date,
                            shipping_geocode: @happyquote.shipping_geocode,
                            shipping_lat: @happyquote.shipping_lat,
                            shipping_long: @happyquote.shipping_long,
                            shipping_street1: @happyquote.shipping_street1,
                            shipping_street2: @happyquote.shipping_street2,
                            shipping_city: @happyquote.shipping_city,
                            shipping_state: @happyquote.shipping_state,
                            shipping_zipcode: @happyquote.shipping_zipcode,
                            shipping_county: @happyquote.shipping_county,
                            shipaddress_same_billaddress: @happyquote.shipaddress_same_billaddress,
                            shipping_amount: @happyquote.shipping_amount,
                            price: @happyquote.price,
                            item_total: @happyquote.item_total,
                            total: @happyquote.total,
                            order_subtotal: @happyquote.order_subtotal,
                            adjustment_total: @happyquote.adjustment_total,
                            state: 'Purchase',
                            user_name: @happyquote.user_name,
                            payment_total: @happyquote.payment_total,
                            shipment_state: @happyquote.shipment_state,
                            payment_state: @happyquote.payment_state,
                            email: @happyquote.email,
                            special_instructions: "",
                            internal_notes: @happyquote.internal_notes,
                            external_notes: @happyquote.special_instructions,
                            currency: @happyquote.currency,
                            shipment_total: @happyquote.shipment_total,
                            tax_rate: @happyquote.tax_rate,
                            additional_tax_total: @happyquote.additional_tax_total,
                            discount_total: @happyquote.discount_total,
                            included_tax_total: @happyquote.included_tax_total,
                            item_count: @happyquote.item_count,
                            po_image: '',
                            po_image_url: '',
                            approved_at: '',
                            approver_name: '',
                            confirmation_delivered: false,
                            discount_override: @happyquote.discount_override,
                            tax_override: @happyquote.tax_override,
                            mailing_street1: @happyquote.mailing_street1,
                            mailing_street2: @happyquote.mailing_street2,
                            mailing_city: @happyquote.mailing_city,
                            mailing_state: @happyquote.mailing_state,
                            mailing_zipcode: @happyquote.mailing_zipcode,
                            copy: @happyquote.copy,
                            status: @happyquote.status,
                            user_id: current_user.id,
                            user_id_add: current_user.id,
                            active: @happyquote.active)


    if happyPo.save
      #flash[:success] = "Purchase Order Header saved!"

        #@happyPoID = happyPo.id

        #linePosition = 1

        #@happyquote.happy_quote_lines.each { |line|
          #@happyPoLine = HappyPoLine.new(
              #happy_po_id: @happyPoID,
              #number: line.number,
              #position: linePosition,
              #product_id: line.product_id,
              #vendor_product_id: line.vendor_product_id,
              #customer_product_id: line.customer_product_id,
              #description: line.description,
              #color: line.color,
              #unit_of_measure: line.unit_of_measure,
              #quantity: line.quantity,
              #quantity_received: 0.0,
              ##last_received_date: NULL, 
              #taxable: line.taxable,
              #tax_amount: line.tax_amount,
              #shipping_amount: line.shipping_amount,
              #list_price: line.list_price,
              #discount: line.discount,
              #unit_price: line.buyout_unit_price,
              #msrp_amount: line.msrp_amount,
              #total_line_amount: line.total_cost_amount,
              #adjustments: line.adjustments,
              #happy_vendor_id: line.happy_vendor_id,
              #vendor_name: line.vendor_name,
              #buyout_unit_price: line.buyout_unit_price,
              #margin: line.margin,
              #total_cost_amount: line.total_cost_amount,
              #internal_notes: line.internal_notes,
              #external_notes: line.external_notes,
              #weight: line.weight,
              #purchase_discount: line.purchase_discount,
              #sell_discount: line.sell_discount,
              ##po_line_image: NULL,
              ##po_line_image_url: NULL,
              ##status: NULL,
              #user_id: current_user.id,
              #user_id_add: current_user.id,
              #active: line.active)
            #@happyPoLine.save
            #linePosition += 1
#        }

        #@happyquote.update(order_date: Date.today, state: "PO")
       
    flash.notice = "Purchase Order: #{@happyvendor.id}-#{@happyquote.number}-#{@happyquote.sub} created."
    #flash[:success] = "Purchase Order Header saved!"

    redirect_to happy_quote_pocreate_url(@happyquote, vendor_id: params[:vendor_id], status: 'final') #, :action =>'pocreate') #, action: 'pocreate', vendor_id: params[:vendor_id], status: 'final')
      #redirect_to happyPo
    else
      flash[:alert] = "Purchase Order not saved!"
      # This line overrides the default rendering behavior, which
      # would have been to render the "create" view.
      # I had to add below to get vendor select box to work after validation fails
      # render new needs to be there but not sure why below does not execute in new method
      #@happyvendors = HappyVendor.all.order("vendor_name asc")
      #render :new
    end

   #user_id_update: @happyquote.,
   #created_at: @happyquote.,
   #updated_at: @happyquote.,
   #lock_version: @happyquote.,
   #canceled_at: '',
   #canceler_id: '',
                            #deliver_not_before_date: @happyquote.deliver_not_before_date,
                            #deliver_not_after_date: @happyquote.deliver_not_after_date,
     end # if happyPo end
  end

   def poprint
     @taxAmount = 0
     @discountAmount = 0
     @pototal = 0
     respond_to do |format|
      format.html
      format.pdf
    end
     @useremail = current_user.email
     @happyvendor = HappyVendor.find(params[:vendor_id])
     #@filename = "happy_quote.pdf"
     @balance = 0
     # this query worked poID = HappyPo.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_po_id], params[:vendor_id])
     #@happypo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).where("happy_pos.happy_vendor_id =?", params[:vendor_id]).order("happy_po_lines.position asc").where(happy_quote_id = (params[:happy_po_id]))
     #@happypo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).where("happy_quote_id =? and happy_vendor_id =?", params[:happy_po_id], params[:vendor_id]).order("happy_po_lines.position asc")
     @happypo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).where("happy_pos.happy_vendor_id =?", params[:vendor_id]).order("happy_po_lines.position asc").find(params[:happy_po_id])
       puts "below happypo"
     @discountAmount = HappyPoLine.where("happy_po_id = ?", @happypo.id).sum('sell_discount')
     @pototal = @balance + HappyPoLine.where("happy_po_id = ?", @happypo.id).sum('total_cost_amount')
     puts "variables"
     puts @discountAmount
     puts @pototal
     #@discountAmount = HappyPoLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_po_id], params[:vendor_id]).sum('sell_discount')
     #@pototal = @balance + HappyPoLine.where("happy_quote_id =? and happy_vendor_id =?", params[:happy_po_id], params[:vendor_id]).sum('total_cost_amount')
     #@quotetotal = @balance + HappyQuoteLine.sum('total_line_amount').where("happy_quote_id =?",params[:id])
     #@happyquote = HappyQuote.where("happy_customer_id = ?", params[:customer_id])
     #@happypo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).where("happy_pos.happy_vendor_id =?", params[:vendor_id]).order("happy_po_lines.position asc").where(happy_quote_id = (params[:happy_po_id]))
     #if @happyquote.order_date.nil?
     #  @happyquote.update_attribute(:order_date, Date.today)
     #end
       insertPo = request.format
       puts "insertPo"
       puts insertPo
     @lines = @happypo.happy_po_lines
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
     #params.each do |key,value|
     #   Rails.logger.warn "Param #{key}: #{value}"
     #end
     puts "got in move" 
      # ** this works @happyquoteline=HappyQuoteLine.find 123
      #@happyquoteline=HappyQuoteLine.find 123
      #below works but happy_quote_id's value is happy_quote_lines.id 
      @happyquoteline=HappyQuoteLine.find(params[:happy_quote_id]) 
      #@happyquoteline=HappyQuoteLine.where("id =?",params[:happy_quote_id])
      @happyquoteline.insert_at(params[:position].to_i)
    head :ok
  end

private

  def find_po
    @happypo = HappyPo.includes(:happy_customer).includes(:happy_po_lines).order("happy_po_lines.position asc").find(params[:id])
    @happyvendor = HappyVendor.find(@happypo.happy_vendor_id)
  end

  def set_s3_object
    s3 = Aws::S3::Resource.new(region: ENV.fetch("AWS_REGION"),
        access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
        secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"))
    bucket_name = ENV.fetch("AWS_BUCKET_NAME")
    @key = "hello_world.pdf"
    @s3_obj = s3.bucket(bucket_name).object(@key)
  end

  def happypo_params
    params.require(:happy_po).permit(
   :happy_customer_id, :terms, :fob, :quote_date, :requested_ship_date, :estimated_delivery_date,
   :deliver_not_before_date, :deliver_not_after_date,
   :email, :customer_id, :customer_name, :shipaddress_same_billaddress,
   :shipping_street1, :shipping_street2, :shipping_city, :shipping_state, :shipping_zipcode,
   :mailing_street1, :mailing_street2, :mailing_city, :mailing_state, :mailing_zipcode,
   :special_instructions, :internal_notes, :external_notes,:user_id,
   :tax_override, :tax_rate, :additional_tax_total,:discount_override, :discount_total, :user_name,
    happy_po_lines_attributes: [:id, :product_id,
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
     :po_subtotal,
     :po_margin,
     :external_notes,
     :internal_notes,
     :_destroy]
)
  end
#Unpermitted parameters: :quote_subtotal, :total_cost_amount, :quote_margin
#Unpermitted parameters: :special_instructions, :internal_notes, :external_notes

  def happyquotenew_params
    params.permit( :happy_customer_id )
  end

  #def discount_tax_calc
    #ZipTax.key="gWiqheMSO7RUQ6Gm"
    #if @happyquote.discount_override then
          #@discountAmount = @happyquote.discount_total
    #else
          #@discountAmount = 0
    #end

    #if @happyquote.happy_customer.taxable then
      #if @happyquote.tax_override and @happyquote.additional_tax_total? then
      #          @taxAmount = @happyquote.additional_tax_total
      #else
          #begin
          #       @taxRate=ZipTax.rate(@happyquote.shipping_zipcode)
          #       puts @quoteTaxTotal
          #       puts @taxRate
          #       @taxAmount = @quoteTaxTotal * @taxRate
          #rescue
          #end
          #@taxAmount = 0
      #end
      #else
        #@taxAmount = 0
      #end
    #end # discount_tax_calc end
end
