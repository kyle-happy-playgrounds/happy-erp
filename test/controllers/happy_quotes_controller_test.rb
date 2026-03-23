require "test_helper"

class HappyQuotesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
  end

  #index
  test "should get search page for quotes" do
    get happy_quotes_path
    assert_response :success
    
  end
  test "should get quote based on quote number" do
    quote = HappyQuote.first
    get happy_quotes_path, params: {search: {
      number: quote.number
    }}
    assert_response :success
    assert_select "h2", text: "Happy Quote"
    assert_select "td", text: "#{quote.number}-#{quote.sub}"
  end

  test "should get quotes based on customer " do
    customer = HappyCustomer.first
    quotes = HappyQuote.where("happy_customer_id = ?", customer.id)
    get happy_quotes_path, params: {
      customer_id: customer.id,
      customer_name: customer.customer_name
    }
    assert_response :success
    assert_select "h2", text: "Happy Quotes for - #{customer.customer_name}"
    quotes.each do |quote|
      assert_select "td", text: "#{quote.number}-#{quote.sub}"
    end
  end

  #new
  test "should show new page with customer info" do
    customer = HappyCustomer.first

    silence_stream(STDOUT) do 
      get new_happy_customer_happy_quote_path(customer)
    end
    assert_response :success
    assert_select "h3", text: "Create a Quote Header"
    assert_select "a[href=?]", edit_happy_customer_path(customer)
    assert_select "input[name=?][value=?]", "happy_quote[mailing_street1]", customer.mailing_street1
    assert_select "a", text: "add line"
  end

  #show
  test "should show quote page" do
    quote = HappyQuote.first
    silence_stream(STDOUT) do 
      get happy_quote_path(quote)
    end
    quotetotal = HappyQuoteLine.where("happy_quote_id =?",quote.id).sum('total_line_amount')
    formatted_total = ActionController::Base.helpers.number_to_currency(quotetotal)
    assert_response :success
    assert_match "#{quote.number}-#{quote.sub}", response.body
    assert_match formatted_total, response.body
  end

  test "should get pdf from show page" do
    quote = HappyQuote.first
    silence_stream(STDOUT) do 
      get happy_quote_path(quote, format: :pdf)
    end
    assert_response :success
    assert_equal "application/pdf; charset=utf-8", response.content_type
  end

  test "should display quote reminders if they exist" do
    quote = HappyQuote.first
    silence_stream(STDOUT) do 
      get happy_quote_path(quote)
    end
    assert_response :success
    assert_select "button", text: "View Quote Reminders"
  end


  #edit
  test "should show edit quote page" do
    quote = HappyQuote.first 
    silence_stream(STDOUT) do 
      get edit_happy_quote_path(quote)
    end
    assert_response :success
    assert_select "h3", text: "Edit Quote Header"
    assert_select "h5", text: "Quote Number: #{quote.number}-#{quote.sub}"
  end

  #update
  test "should update quote info" do
    quote = HappyQuote.first
    line = quote.happy_quote_lines.first
    line_two = quote.happy_quote_lines.second
    silence_stream(STDOUT) do 
      assert_changes -> {quote.reload.mailing_street1} do
        patch happy_quote_path(quote), params: {
          happy_quote: {
            happy_customer_id: quote.happy_customer_id,
            mailing_street1: "999 New Street Ave",
            mailing_city: "Place",
            mailing_state: "OK",
            mailing_zipcode: "12345",
            shipping_street1: "999 New Street Ave",
            shipping_city: "Place",
            shipping_state: "OK",
            shipping_zipcode: "12345",
            terms: "Net 30 days",
            fob: "LTL Carrier",
            happy_quote_lines_attributes: {
              "0" => {
                id: line.id,
                unit_price: line.unit_price.to_s,
                buyout_unit_price: line.buyout_unit_price.to_s,
                quantity: line.quantity,
                total_line_amount: line.total_line_amount.to_s
              },
              "1" => {
                id: line_two.id,
                unit_price: line_two.unit_price.to_s,
                buyout_unit_price: line_two.buyout_unit_price.to_s,
                quantity: line_two.quantity,
                total_line_amount: line_two.total_line_amount.to_s
              }
            }
          }
        }
      end
    end
    assert_redirected_to happy_quote_path(quote)
  end

  #copy
  test "should copy quote to sub" do
    quote = HappyQuote.first
    silence_stream(STDOUT) do 
      get happy_quote_copy_path(quote)
      quotecopy = HappyQuote.last
      assert_redirected_to edit_happy_quote_path(quotecopy)
      follow_redirect!
      assert_equal "Quote: #{quote.number}-#{quote.sub+1} created.", flash[:notice]
      assert_equal "#{quote.number}-#{quote.sub+1}", "#{quotecopy.number}-#{quotecopy.sub}"
      assert_select "h5", text: "Quote Number: #{quotecopy.number}-#{quotecopy.sub}"
    end
  end

  #po
  test "should show po's for quote " do
    quote = HappyQuote.first
    line = quote.happy_quote_lines.first
    line_two = quote.happy_quote_lines.second
    silence_stream(STDOUT) do 
      get happy_quote_po_path(quote), params: {
        happy_customer_id: quote.happy_customer_id,
        happy_quote_id: quote.id}
      assert_response :success
      assert_select "h3", text: "Happy Vendors for Quote # - #{quote.number}-#{quote.sub}"
      assert_select "td", text: line.happy_vendor_id.to_s
      assert_select "td", text: "Vendor 1"
      assert_select "td", text: line_two.happy_vendor_id.to_s
      assert_select "td", text: "Vendor 2"
    end
  end

  #pocreate
  test "should show page for indviudal po draft" do
    quote = HappyQuote.first
    draft_line= quote.happy_quote_lines.second
    vendor = HappyVendor.second
    silence_stream(STDOUT) do 
      get happy_quote_pocreate_path(quote), params: {status: "draft", vendor_id: draft_line.happy_vendor_id}
      assert_response :success
      assert_select "h4", text: "Draft"
      assert_match "P.O. #: #{draft_line.happy_vendor_id}-#{quote.number}-#{quote.sub}", response.body
      assert_match "#{vendor.vendor_name}<br>
      #{vendor.mailing_street1}<br>
      #{vendor.mailing_city}, #{vendor.mailing_state} #{vendor.mailing_zipcode}<br>
      #{vendor.business_phone}", response.body
      assert_select ".col-sm-2", text: draft_line.product_id
      assert_select ".col-sm-3", text: draft_line.description
      assert_select "div.float-right", text: ActionController::Base.helpers.number_to_currency(draft_line.buyout_unit_price)
      assert_select "a", text:"Finalize P.O."
    end
  end

  test "should show page for indviudal po finalized" do
    quote = HappyQuote.first
    final_line= quote.happy_quote_lines.first
    vendor = HappyVendor.first
    silence_stream(STDOUT) do 
      get happy_quote_pocreate_path(quote), params: {status: "final", vendor_id: final_line.happy_vendor_id}
      assert_response :success
      assert_select "h4", text: "Final"
      assert_match "P.O. #: #{final_line.happy_vendor_id}-#{quote.number}-#{quote.sub}", response.body
      assert_match "#{vendor.vendor_name}<br>
      #{vendor.mailing_street1}<br>
      #{vendor.mailing_city}, #{vendor.mailing_state} #{vendor.mailing_zipcode}<br>
      #{vendor.business_phone}", response.body
      assert_select ".col-sm-2", text: final_line.product_id
      assert_select ".col-sm-3", text: final_line.description
      assert_select "div.float-right", text: ActionController::Base.helpers.number_to_currency(final_line.buyout_unit_price)
      assert_select "a", text:"Finalize P.O.", count: 0
    end
  end

  test "should get pdf from PO page" do
    quote = HappyQuote.first
    final_line= quote.happy_quote_lines.first
    silence_stream(STDOUT) do 
      get happy_quote_pocreate_path(quote), params: {status: "final", vendor_id: final_line.happy_vendor_id, format: "pdf"}
    end
    assert_response :success
    assert_equal "application/pdf; charset=utf-8", response.content_type
  end

  #pwfreight
  test "should show freight form for quote" do
    quote = HappyQuote.first
    vendor = HappyVendor.first
    silence_stream(STDOUT) do 
      get happy_quote_pwfreight_path(quote), params: {happy_quote_id: quote.id , vendor_id: vendor.id, format: "html"}
    end
    assert_response :success
    assert_select "h2", text: "PlayWorld Freight Form"
  end
  test "should get pdf freight form" do
    quote = HappyQuote.first
    vendor = HappyVendor.first
    silence_stream(STDOUT) do 
      get happy_quote_pwfreight_path(quote), params: {happy_quote_id: quote.id , vendor_id: vendor.id, format: "pdf", submit: {customer_type: "Church"}}
    end
    assert_response :success
    assert_equal "application/pdf; charset=utf-8", response.content_type
  end

  #move
  test "should move line items on show page" do
    quote = HappyQuote.first
    line_one = HappyQuoteLine.first
    line_two = HappyQuoteLine.second
    assert_equal line_one.position, 1
    assert_equal line_two.position, 2
    silence_stream(STDOUT) do 
      assert_changes -> {line_one.reload.position} do
        patch happy_quote_move_path(quote), params: {happy_quote_id: quote.id, position: line_two.position}
      end
  end
    assert_equal line_one.reload.position, 2
    assert_equal line_two.reload.position, 1
  end 

  #setstatus
  test "should set status of quote" do 
    quote = HappyQuote.first 
    silence_stream(STDOUT) do 
      assert_no_changes -> {quote.reload.status} do
        patch set_status_happy_quote_path(quote), params: {status: "invalid"}
      end
      assert_changes -> {quote.reload.status}, from: "open", to: "draft" do
        patch set_status_happy_quote_path(quote), params: {status: "draft"}
      end
      assert_changes -> {quote.reload.status}, from: "draft", to: "won" do
        patch set_status_happy_quote_path(quote), params: {status: "won"}
      end
      assert_changes -> {quote.reload.status} do
        patch set_status_happy_quote_path(quote), params: {status: "lost"}
      end
    end
  end

  #start
  test "should show start quote page" do
    companies = HappyCustomerCompany.all
    get start_happy_quotes_path
    assert_response :success
    assert_select 'h2', text: "Start a Quote"
    assert_select "option", text: "Select a company…"
    companies.each do |company| 
      assert_select "option", text: company.company_name
    end
  end
  test "should show all customers under company" do 
    company = HappyCustomerCompany.first
    customers = HappyCustomer.where(happy_customer_company_id: company.id).order(:customer_name)
    get start_happy_quotes_path, params: {happy_customer_company_id: company.id}
    assert_response :success
    customers.each do |customer| 
      assert_select "option", text: customer.customer_name
    end
  end

  #start_create
  test "should redirect back to start if invalid info" do
    company = HappyCustomerCompany.first

    post start_create_happy_quotes_path, params: {happy_customer_company_id: company.id } #no customer data
    assert_redirected_to start_happy_quotes_path(happy_customer_company_id: company.id )
    assert_equal "Please select a customer.", flash[:alert]
  end

  test "should redirect to create if valid info" do
    company = HappyCustomerCompany.first
    customer = HappyCustomer.first
    post start_create_happy_quotes_path, params: {happy_customer_company_id: company.id, happy_customer_id: customer.id} #no customer data
    assert_redirected_to new_happy_quote_path(happy_customer_id: customer.id )

  end

end
