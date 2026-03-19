
# edit.pdf.prawn

test = "PO-"+@happyvendor.vendor_name+"-"+@happyvendor.id.to_s+"-"+@happyquote.number.to_s+"-"+@happyquote.sub.to_s+"-"+DateTime.now.strftime('%m-%d-%Y-%H%M%S').to_s+".pdf"
#test = "tmp/test.pdf"

prawn_document(filename: test, disposition: "attachment") do |pdf|

  logopath = 'HP_Logo.jpg'     
  initial_y = pdf.cursor       
  initialmove_y = 5            
  address_x = 0                
  quote_header_x = 350         
  quote_certs_x = 355          
  lineheight_y = 12            
  font_size = 9                
  
  pdf.move_down initialmove_y  
  
  # Add the font style and size
  pdf.font "Helvetica"         
  pdf.font_size font_size  

     #body minus used to be 180
     pdf.bounding_box [pdf.bounds.left, (pdf.bounds.top - 200)], :width  => pdf.bounds.width + 18, :height => 530 do
     quote_items_header = ["Item", "Quantity","UOM", "Description","Color", "Unit Price", "Total"]

  quote_items_data = []
  quote_items_data << quote_items_header

  @happyquote.happy_quote_lines.map do |item|
 	if item.quantity == 0              
           quote_items_data << [ " ", " ", " ","heading-"+item.description," ", " ", " " ]
	else
           quote_items_data << [ item.product_id, item.quantity, item.unit_of_measure,item.description,item.color, number_to_currency(item.buyout_unit_price), number_to_currency(item.total_cost_amount) ]
	end
  end


  quote_items_data << [" ", " "," ", " ", " "," ", " "]


  pdf.table(quote_items_data, :width => pdf.bounds.width, :header => true) do
    style(row(1..-1).columns(0..-1), :padding => [4, 5, 4, 5], :borders => [:bottom], :border_color => 'dddddd')
    style(row(0), :background_color => 'e9e9e9', :border_color => 'dddddd', :font_style => :bold)
    style(row(0).columns(0..-1), :borders => [:top, :left, :right, :bottom])
    style(row(0).columns(0), :borders => [:top, :left, :bottom])
    style(row(-1), :border_width => 10)
    style(column(3..-1), :align => :left)
    style(column(4..-1), :align => :left)
    style(column(5..-1), :align => :right)
    style(column(6..-1), :align => :right)
    style(column(1), :align => :right)
    style(columns(0), :width => 75)
    style(columns(2), :width => 30)
    style(columns(3), :width => 200)
    style(columns(4), :width => 65)
    column(3).style do |cell|
       #if cell.content.match(/[\n,*]/)
       #  cell.style(:font_style => :italic)
       #end
       if cell.content.slice(0,8) == "heading-"
         cell.content = cell.content.slice(8..-1)
         cell.style(:font_style => :bold)
       end
    end
  end

     if pdf.cursor < 200
        #pdf.text pdf.cursor, :size => 14
        pdf.start_new_page
        pdf.stroke_horizontal_rule
        subtotal_y = 500 
     else
        subtotal_y = pdf.cursor - 25 
     end

     last_measured_y = pdf.cursor

  special_instructions_data = [ 
    [@happyquote.external_notes],
    [@happyquote.special_instructions]
  ]

  pdf.move_down 25

  pdf.table(special_instructions_data, :width => 275) do
    style(row(0..-1).columns(0..-1), :padding => [1, 0, 1, 0], :borders => [])
    style(row(0).columns(0), :font_style => :bold)
  end
     #pdf.bounding_box [pdf.bounds.left, (pdf.bounds.bottom + subtotal_y)], :width  => pdf.bounds.width do

     #pdf.float do
     	#pdf.bounding_box([0,pdf.cursor], width: 200, height: 70) do
    		#pdf.pad_top(60) { pdf.text 'Signature/Date', align: :center }
  		#pdf.stroke_bounds
     		#end
     #end
#end

     pdf.move_cursor_to last_measured_y

     pdf.bounding_box [pdf.bounds.left, (pdf.bounds.bottom + subtotal_y)], :width  => pdf.bounds.width do
quote_items_totals_data = [ 
    ["Sub Total", number_to_currency(@pototal)],
    ["Tax", number_to_currency(@taxAmount)],
    ["Discount", number_to_currency(@discountAmount)],
    ["Purchase Order Amount", number_to_currency(@pototal + @taxAmount - @discountAmount)],
  ]

  pdf.table(quote_items_totals_data, :position => quote_header_x, :width => 200) do
    style(row(0..1).columns(0..1), :padding => [1, 5, 1, 5], :borders => [])
    style(row(0), :font_style => :bold)
    style(row(2), :background_color => 'e9e9e9', :border_color => 'dddddd', :font_style => :bold)
    style(column(1), :align => :right)
    style(row(2).columns(0), :borders => [:top, :left, :bottom])
    style(row(2).columns(1), :borders => [:top, :right, :bottom])
  end

  		#pdf.move_down 60
  		pdf.move_down lineheight_y
  		pdf.fill_color "DA251D"
  		pdf.text_box "Please submit all invoices to: ", :at => [quote_certs_x,  pdf.cursor], :mode => :fill
  		pdf.move_down lineheight_y
  		pdf.text_box "accounting@happyplaygrounds.com", :at => [quote_certs_x,  pdf.cursor], :mode => :fill
  		pdf.fill_color "000000"
  


  #pdf.move_down 10


  #pdf.move_down 15

#  image_path = "#{Rails.root}/app/assets/images/happy-smiley.png"
#  quote_notes_data = [ 
#    ["Notes"],
#    ["Thank you for doing business with Happy Playgrounds, LLC"],
#    [{:image => image_path, :scale => 0.25}]
#  ]

#  pdf.table(quote_notes_data, :width => 275) do
#    style(row(0..-1).columns(0..-1), :padding => [1, 0, 1, 0], :borders => [])
#    style(row(0).columns(0), :font_style => :bold)
#  end

#pdf.move_down 15

#  receipt_storage = [ 
#    ["Receipt & Storage of Product:"],
#    ["Unless agreed upon ahead of time, the customer is responsible for unloading product from the truck and checking the bill of lading for missing equipment and/or damages. Please check deliveries carefully. Anything missing or damaged should be noted on the bill of lading when signing for the shipment. Photographs of damaged equipment should be taken and forwarded to us."]
#  ]

#  pdf.table(receipt_storage) do
#    style(row(0..-1).columns(0..-1), :padding => [1, 0, 1, 0], :borders => [])
#    style(row(0).columns(0), :font_style => :bold)
#  end

#pdf.move_down 10
#  installation = [ 
#    ["Installation:"],
#    ["Our installation prices are based upon the site being graded and ready for the equipment, with no large rocks that may interfere with drilling the foundation. If large rocks or other obstacles are found which were unanticipated, there may be additional costs involved. We will notify the owner before proceeding. "]
#  ]

#  pdf.table(installation) do
#    style(row(0..-1).columns(0..-1), :padding => [1, 0, 1, 0], :borders => [])
#    style(row(0).columns(0), :font_style => :bold)
#  end

end # end bounding box for subtotal


end


    pdf.repeat :all do

        # header
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], :width  => pdf.bounds.width do
  		pdf.text_box "Purchase Order", :at => [address_x,  pdf.cursor], size: 18

  		pdf.move_cursor_to pdf.bounds.height - 20

  		po_header_data = [ 
    		["P.O. #:", @happyvendor.id.to_s+"-"+@happyquote.number.to_s+"-"+@happyquote.sub.to_s],
    		["P.O. Date:", @happyquote.order_date.strftime("%m-%d-%Y")]
  		]

  		pdf.table(po_header_data, :width => 200, :column_widths => [50, 150]) do
    		style(row(0..-1).columns(0..1), :padding => [0, 0, 0, 0], :borders => [])
    		style(column(1), :align => :left)
  		end

  		pdf.move_cursor_to pdf.bounds.height - 60
                pdf.text_box "Happy Playgrounds, LLC", :at => [address_x,  pdf.cursor]
  		pdf.move_down lineheight_y   
  		pdf.text_box "7170 S Braden Ave Suite 195", :at => [address_x,  pdf.cursor]
  		pdf.move_down lineheight_y   
  		pdf.text_box "Tulsa, OK 74136", :at => [address_x,  pdf.cursor]
  		pdf.move_down lineheight_y   
  		pdf.text_box "(918) 851-9518", :at => [address_x,  pdf.cursor]
  		pdf.move_down lineheight_y   
  		pdf.fill_color "0093DD"
  		pdf.text_box @useremail, :at => [address_x,  pdf.cursor], :size => 8, :mode => :fill
  		pdf.fill_color "000000"
  		pdf.move_down lineheight_y
		
  		last_measured_y = pdf.cursor
  		pdf.move_cursor_to pdf.bounds.height
		
  		#pdf.move_down 60
  		pdf.move_down lineheight_y
  		pdf.fill_color "DA251D"
  		pdf.text_box "Certified Woman Owned Small Business", :at => [quote_certs_x,  pdf.cursor], :mode => :fill
  		pdf.move_down lineheight_y
  		pdf.text_box "Native American Owned:", :at => [quote_certs_x,  pdf.cursor], :mode => :fill
  		pdf.move_down lineheight_y
  		pdf.text_box "TERO and CESO certified", :at => [quote_certs_x,  pdf.cursor], :mode => :fill
  		pdf.fill_color "000000"
  

  		last_measured_y = pdf.cursor
  		pdf.move_cursor_to pdf.bounds.height

  		require 'open-uri'
  		pdf.image URI.open("https://happypg-prod.s3.amazonaws.com/logo_v1.png"), :width => 150, :position => :center

  		# client address
  		pdf.move_cursor_to pdf.bounds.height - 130

		vendor_header_data = [ 
    		["VENDOR:", @happyvendor.vendor_name],
    		["", @happyvendor.mailing_street1],
    		["", @happyvendor.mailing_street2],
    		["", @happyvendor.mailing_city+", "+@happyvendor.mailing_state+" "+@happyvendor.mailing_zipcode],
    		["", @happyvendor.business_phone]
		]
		
  		pdf.table(vendor_header_data,  :width => 200,  :column_widths => [50, 150]) do
    		style(row(0..-1).columns(0..1), :padding => [0, 5, 1, 0], :borders => [])
    		style(column(1), :align => :left)
  		end



  		pdf.move_cursor_to pdf.bounds.height - 60

    		#["Customer:", @happyquote.happy_customer.customer_name],
    		#["Address:", @happyquote.happy_customer.mailing_street1],
    		#["", @happyquote.happy_customer.mailing_city+", "+@happyquote.happy_customer.mailing_state+" "+@happyquote.happy_customer.mailing_zipcode]
		
  		#po_header_data = [ 
    		#["P.O. #:", @happyvendor.id.to_s+"-"+@happyquote.id.to_s],
    		#["Purchase Order Date:", @happyquote.quote_date.strftime("%m-%d-%Y")]
  		#]
#
  		#pdf.table(po_header_data, :position => quote_header_x, :width => 215) do
    		#style(row(0..-1).columns(0..1), :padding => [0, 5, 1, 5], :borders => [])
    		#style(column(1), :align => :left)
  		#end

  		# client address
  		pdf.move_cursor_to pdf.bounds.height - 130

		shipto_header_data = [ 
    		["SHIP TO:", @happyquote.happy_customer.customer_name],
    		["", @happyquote.shipping_street1],
    		["", @happyquote.shipping_street2],
    		["", @happyquote.shipping_city+", "+@happyquote.shipping_state+" "+@happyquote.shipping_zipcode]
		]
		
  		pdf.table(shipto_header_data, :position => quote_header_x, :width => 200,  :column_widths => [50, 150]) do
    		style(row(0..-1).columns(0..1), :padding => [0, 5, 1, 0], :borders => [])
    		style(column(1), :align => :left)
  		end
  if @happyquote.project_title.present?
    pdf.move_down 10
    pdf.text "PROJECT:  #{@happyquote.project_title}", inline_format: true

  end

  		pdf.move_down 115
      
        	
	end

        # footer
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 25], :width  => pdf.bounds.width do
            pdf.font "Helvetica"
            pdf.stroke_horizontal_rule
            pdf.move_down 5
            pdf.text "Happy Playgrounds, LLC", :size => 12
            pdf.move_down 10
            pdf.formatted_text_box( [{ text: 'www.happyplaygrounds.com',
                         color: '8E84B7',
                         link: 'https://www.happyplaygrounds.com'}], at: [1,7], width: 130, height: 10)
        end # bounding footer
    end

    string = "page <page> of <total>"
    # Green page numbers 1 to 11
    options = { :at => [pdf.bounds.right - 150, 0],
     :width => 150,
     :align => :right,
     :page_filter => (1..11),
     :start_count_at => 1,
     :color => "84C225" }
    pdf.number_pages string, options
end # Prawn ddo

