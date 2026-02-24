
# edit.pdf.prawn

if !@happyquote.user_name.blank? 
	test = @happyquote.user_name+"-"+@happyquote.happy_customer.customer_name+"-"+@happyquote.number+"-"+@happyquote.sub.to_s+"-"+DateTime.now.in_time_zone("Central Time (US & Canada)").strftime('%m-%d-%Y-%H%M%S').to_s+".pdf"
else
	test = @happyquote.happy_customer.customer_name+"-"+@happyquote.number+"-"+@happyquote.sub.to_s+"-"+DateTime.now.in_time_zone("Central Time (US & Canada)").strftime('%m-%d-%Y-%H%M%S').to_s+".pdf"
end

#test = @happyquote.happy_customer.customer_name+"-"+@happyquote.id.to_s+"-"+DateTime.now.in_time_zone("Central Time (US & Canada)").strftime('%m-%d-%Y-%H%M%S').to_s+".pdf"
#test = "tmp/test.pdf"

prawn_document(filename: test, disposition: "attachment") do |pdf|
#prawn_document() do |pdf|

  logopath = 'HP_Logo.jpg'     
  initial_y = pdf.cursor       
  initialmove_y = 5            
  address_x = 0                
  quote_sub_x = 325         
  quote_header_x = 385         
  quote_certs_x = 375          
  logo_x = 188          
  lineheight_y = 12            
  font_size = 9                
  
  pdf.move_down initialmove_y  
  
  # Add the font style and size
  pdf.font "Helvetica"         
  pdf.font_size font_size  

     #body
     pdf.bounding_box [pdf.bounds.left, (pdf.bounds.top - 180)], :width  => pdf.bounds.width + 18, :height => 530 do
     quote_items_header = ["Item", "Quantity","UOM", "Description","Color", "Unit Price", "Total"]

  quote_items_data = []
  quote_items_data << quote_items_header

  @happyquote.happy_quote_lines.map do |item|
           if !item.external_notes.blank? 
           	quote_items_data << [ item.product_id, item.quantity, item.unit_of_measure,"#{item.description} #{"\n"} #{"*  "}#{item.external_notes}#{"  *"}",item.color, number_to_currency(item.unit_price), number_to_currency(item.total_line_amount) ]
           else
           	if  item.quantity == 0 
           		quote_items_data << [ " ", " ", " ","heading-"+item.description," ", " ", " " ]
           	else
           		quote_items_data << [ item.product_id, item.quantity, item.unit_of_measure,item.description,item.color, number_to_currency(item.unit_price), number_to_currency(item.total_line_amount) ]
	   	end
	    end
      
           #if !item.external_notes.blank? 
           #     ex_notes = "*  "+item.external_notes+"  *"
	   #	quote_items_data <<  [" ", " "," ", ex_notes, " "," ", " "]           end 
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
     pdf.bounding_box [pdf.bounds.left, (pdf.bounds.bottom + subtotal_y)], :width  => pdf.bounds.width do

     pdf.float do
     	pdf.bounding_box([0,pdf.cursor], width: 200, height: 70) do
    		pdf.pad_top(60) { pdf.text 'Signature/Date', align: :center }
  		pdf.stroke_bounds
     		end
     end
end

     pdf.move_cursor_to last_measured_y - 25

     # This bounding box ends at very bottom of the code. It is commented
 #    pdf.bounding_box [pdf.bounds.left, (pdf.bounds.bottom + subtotal_y)], :width  => pdf.bounds.width do
      if @discountAmount > 0
	quote_items_totals_data = [ 
    	["Sub Total", number_to_currency(@quotetotal)],
    	["Estimated Tax", number_to_currency(@taxAmount)],
    	["Discount", number_to_currency(@discountAmount)],
    	["Quote Amount", number_to_currency(@quotetotal + @taxAmount - @discountAmount)]
  	]
      else
	quote_items_totals_data = [ 
    	["Sub Total", number_to_currency(@quotetotal)],
    	["Estimated Tax", number_to_currency(@taxAmount)],
    	["Quote Amount", number_to_currency(@quotetotal + @taxAmount - @discountAmount)]
  	]
      end

  pdf.table(quote_items_totals_data, :position => quote_sub_x, :width => 215) do
    style(row(0..1).columns(0..1), :padding => [1, 5, 1, 5], :borders => [])
    style(row(0), :font_style => :bold)
    style(row(2), :background_color => 'e9e9e9', :border_color => 'dddddd', :font_style => :bold)
    style(column(1), :align => :right)
    style(row(2).columns(0), :borders => [:top, :left, :bottom])
    style(row(2).columns(1), :borders => [:top, :right, :bottom])
  end

  pdf.move_down 10

  external_notes_data = [ 
    [@happyquote.external_notes]
  ]

  #pdf.table(external_notes_data, :width => 275) do
  #  style(row(0..-1).columns(0..-1), :padding => [1, 0, 1, 0], :borders => [])
  #  style(row(0).columns(0), :font_style => :bold)
  #end

  pdf.move_down 20

  image_path = "#{Rails.root}/app/assets/images/happy-smiley.png"
  
 if @happyquote.external_notes? 
  quote_notes_data = [ 
    ["Thank you for doing business with Happy Playgrounds, LLC", {:image => image_path, :scale => 0.25}],
    ["Notes:",""],
    [external_notes_data,""],
  ]
 else
  quote_notes_data = [ 
    ["Thank you for doing business with Happy Playgrounds, LLC", {:image => image_path, :scale => 0.25}],
  ]
end

  pdf.table(quote_notes_data, :width => 541.28) do
    style(row(0..-1).columns(0..-1), :padding => [1, 0, 1, 0], :borders => [])
    style(row(0..-1).columns(0), :font_style => :bold)
    style(column(0), :align => :left)
    style(columns(0), :width => 150) 
  end

pdf.move_down 15

  receipt_storage = [ 
    ["Receipt & Storage of Product:",
    "Unless agreed upon ahead of time, the customer is responsible for unloading product from the truck and checking the bill of lading for missing equipment and/or damages. Please check deliveries carefully. Anything missing or damaged should be noted on the bill of lading when signing for the shipment. Photographs of damaged equipment should be taken and forwarded to us."]
  ]

  pdf.table(receipt_storage) do
    style(row(0..-1).columns(0..-1), :padding => [1, 0, 1, 0], :borders => [])
    style(row(0).columns(0), :font_style => :bold)
    style(column(0), :align => :left)
    style(columns(0), :width => 150) 
  end

pdf.move_down 10
  installation = [ 
    ["Installation:",
    "Our installation prices are based upon the site being graded and ready for the equipment, with no large rocks that may interfere with drilling the foundation. If large rocks or other obstacles are found which were unanticipated, there may be additional costs involved. We will notify the owner before proceeding. "]
  ]

  pdf.table(installation) do
    style(row(0..-1).columns(0..-1), :padding => [1, 0, 1, 0], :borders => [])
    style(row(0).columns(0), :font_style => :bold)
    style(column(0), :align => :left)
    style(columns(0), :width => 150) 
  end

#end # end bounding box for subtotal


end


    pdf.repeat :all do

        # header
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], :width  => pdf.bounds.width do
  pdf.text_box "Happy Playgrounds, LLC", :at => [address_x,  pdf.cursor]
  pdf.move_down lineheight_y
  pdf.text_box "7170 S Braden Ave Suite 195", :at => [address_x,  pdf.cursor]
  pdf.move_down lineheight_y
  pdf.text_box "Tulsa, OK 74136", :at => [address_x,  pdf.cursor]
  pdf.move_down lineheight_y + 2
  pdf.text_box "Oklahoma: (918) 992-3278", :at => [address_x,  pdf.cursor]
  pdf.move_down lineheight_y
  pdf.text_box "Arkansas: (479) 364-6145", :at => [address_x,  pdf.cursor]
  pdf.move_down lineheight_y
  pdf.fill_color "0093DD"
  pdf.text_box @useremail, :at => [address_x,  pdf.cursor], :size => 8, :mode => :fill
  pdf.fill_color "000000"
  pdf.move_down lineheight_y

  last_measured_y = pdf.cursor
  pdf.move_cursor_to pdf.bounds.height


  quote_number=@happyquote.number+"-"+@happyquote.sub.to_s
  quote_header_data = [ 
    ["Quote #", quote_number],
    ["Quote Date", @happyquote.quote_date.strftime("%m-%d-%Y")],
    ["Quote Amount", number_to_currency(@quotetotal + @taxAmount - @discountAmount)]
  ]

  pdf.table(quote_header_data, :position => quote_header_x, :width => 150) do
    style(row(0..1).columns(0..1), :padding => [1, 5, 1, 5], :borders => [])
    style(row(2), :background_color => 'e9e9e9', :border_color => 'dddddd', :font_style => :bold)
    style(column(1), :align => :right)
    style(row(2).columns(0), :borders => [:top, :left, :bottom])
    style(row(2).columns(1), :borders => [:top, :right, :bottom])
  end

 # pdf.move_down lineheight_y
 # pdf.fill_color "DA251D"
 # pdf.text_box "Certified Woman Owned Small Business", :at => [quote_certs_x,  pdf.cursor], :mode => :fill
 # pdf.move_down lineheight_y
 # pdf.text_box "Native American Owned:", :at => [quote_certs_x,  pdf.cursor], :mode => :fill
 # pdf.move_down lineheight_y
 # pdf.text_box "TERO and CESO certified", :at => [quote_certs_x,  pdf.cursor], :mode => :fill
 # pdf.fill_color "000000"
  

  last_measured_y = pdf.cursor
  pdf.move_cursor_to pdf.bounds.height

  require 'open-uri'
  pdf.image URI.open("https://happypg-prod.s3.amazonaws.com/logo_v1.png"), :width => 150, :position => :center
  pdf.move_down 7
  pdf.fill_color "C62828"
  pdf.text "Certified Woman Owned Small Business", align: :center, size: 8.5, :mode => :fill
#  pdf.text_box "Native American Owned", :at => [logo_x + 20,  pdf.cursor], :mode => :fill
  pdf.text "Native American Owned", align: :center, size: 8.5,  :mode => :fill
  pdf.text "TERO & CESO Certified", align: :center, size: 8.5,  :mode => :fill
  pdf.fill_color "000000"

  pdf.move_cursor_to last_measured_y


  #pdf.move_down 30

  #quote_number=@happyquote.number+"-"+@happyquote.sub.to_s
  #quote_header_data = [ 
    #["Quote #", quote_number],
    #["Quote Date", @happyquote.quote_date.strftime("%m-%d-%Y")],
    #["Quote Amount", number_to_currency(@quotetotal + @taxAmount - @discountAmount)]
  #]

  #pdf.table(quote_header_data, :position => quote_header_x, :width => 215) do
    #style(row(0..1).columns(0..1), :padding => [1, 5, 1, 5], :borders => [])
    #style(row(2), :background_color => 'e9e9e9', :border_color => 'dddddd', :font_style => :bold)
    #style(column(1), :align => :right)
    #style(row(2).columns(0), :borders => [:top, :left, :bottom])
    #style(row(2).columns(1), :borders => [:top, :right, :bottom])
  #end


  # client address
  #pdf.move_down 65
  pdf.move_down 14
  last_measured_y = pdf.cursor


  pdf.text_box "BILL TO:", :at => [address_x,  pdf.cursor], :style => :bold
  pdf.text_box "SHIP TO:", :at => [quote_header_x,  pdf.cursor], :style => :bold
  pdf.move_down lineheight_y
  pdf.text_box @happyquote.happy_customer.customer_name, :at => [address_x,  pdf.cursor]
  pdf.text_box @happyquote.shipping_street1, :at => [quote_header_x,  pdf.cursor]
  pdf.move_down lineheight_y
  pdf.text_box "Attention: " + @happyquote.happy_customer.first_name + " " + @happyquote.happy_customer.last_name, :at => [address_x,  pdf.cursor]
  if @happyquote.shipping_street2.blank? 
  	pdf.text_box @happyquote.shipping_city + ", " + @happyquote.shipping_state + " " + @happyquote.shipping_zipcode, :at => [quote_header_x,  pdf.cursor]
  else
  	pdf.text_box @happyquote.shipping_street2, :at => [quote_header_x,  pdf.cursor]
  end
  pdf.move_down lineheight_y
  pdf.text_box @happyquote.mailing_street1, :at => [address_x,  pdf.cursor]
  if !@happyquote.shipping_street2.blank? 
  	pdf.text_box @happyquote.shipping_city + ", " + @happyquote.shipping_state + " " + @happyquote.shipping_zipcode, :at => [quote_header_x,  pdf.cursor]
  end
  if !@happyquotemailing_street2.blank? 
  	pdf.move_down lineheight_y
  	pdf.text_box @happyquote.mailing_street2, :at => [address_x,  pdf.cursor]
  end
  pdf.move_down lineheight_y
  pdf.text_box @happyquote.mailing_city + ", " + @happyquote.mailing_state + " " + @happyquote.mailing_zipcode, :at => [address_x,  pdf.cursor]

  #pdf.move_cursor_to 37.0 # was 53 no idea why had to hardcode was pdf.move_cursor_to last_measured_y
  #pdf.move_up 50

  #quote_number=@happyquote.id.to_s+"-"+@happyquote.sub.to_s
  #quote_header_ship_data = [ 
    #["SHIP TO:"],
    #[@happyquote.shipping_street1],
    #[@happyquote.shipping_street2],
    #[@happyquote.shipping_city + ", " + @happyquote.shipping_state + " " + @happyquote.shipping_zipcode]
  #]
#
  #pdf.table(quote_header_ship_data, :position => quote_header_x, :width => 215) do
    #style(row(0..1).columns(0..1), :padding => [1, 5, 1, 5], :borders => [])
    #style(row(2), :background_color => 'e9e9e9', :border_color => 'dddddd', :font_style => :bold)
  #  style(column(1), :align => :right)
  #  style(row(2).columns(0), :borders => [:top, :left, :bottom])
  #  style(row(2).columns(1), :borders => [:top, :right, :bottom])
  #end

  #pdf.text_box "SHIP TO:", :at => [address_x,  pdf.cursor], :style => :bold
  #pdf.move_down lineheight_y
  #pdf.text_box @happyquote.happy_customer.customer_name, :at => [address_x,  pdf.cursor]
  #pdf.move_down lineheight_y
  #pdf.text_box  @happyquote.happy_customer.first_name + " " + @happyquote.happy_customer.last_name, :at => [address_x,  pdf.cursor]
  #pdf.move_down lineheight_y
  #pdf.text_box @happyquote.shipping_street1, :at => [address_x,  pdf.cursor]
  #if !@happyquote.shipping_street2.blank? 
  	#pdf.move_down lineheight_y
  	#pdf.text_box @happyquote.shipping_street2, :at => [address_x,  pdf.cursor]
  #end
  #pdf.move_down lineheight_y
  #pdf.text_box @happyquote.shipping_city + ", " + @happyquote.shipping_state + " " + @happyquote.shipping_zipcode, :at => [address_x,  pdf.cursor]

  #pdf.move_cursor_to 37.0 # was 53 no idea why had to hardcode was pdf.move_cursor_to last_measured_y

  ##quote_number=@happyquote.id.to_s+"-"+@happyquote.sub.to_s
  #quote_number=@happyquote.number+"-"+@happyquote.sub.to_s
  #quote_header_data = [ 
    #["Quote #", quote_number],
    #["Quote Date", @happyquote.quote_date.strftime("%m-%d-%Y")],
    #["Quote Amount", number_to_currency(@quotetotal + @taxAmount - @discountAmount)]
  #]

  #pdf.table(quote_header_data, :position => quote_header_x, :width => 215) do
    #style(row(0..1).columns(0..1), :padding => [1, 5, 1, 5], :borders => [])
    #style(row(2), :background_color => 'e9e9e9', :border_color => 'dddddd', :font_style => :bold)
    #style(column(1), :align => :right)
    #style(row(2).columns(0), :borders => [:top, :left, :bottom])
    #style(row(2).columns(1), :borders => [:top, :right, :bottom])
  #end

  pdf.move_down 45
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


