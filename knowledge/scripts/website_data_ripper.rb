require 'rubygems'
require 'nokogiri'  
require 'open-uri'
require 'json'
require 'CSV'

# http://ruby.bastardsbook.com/chapters/html-parsing/

def clear_field_for_csv text
	return text.strip.gsub(/,/,";").gsub(/\n|•|\r/," ")
end

def print_csv_header csv_target_filename
	CSV.open(csv_target_filename, "wb") do |csv|		
		csv << ["Title","Price","Location","Area","Time","URL"]
	end
end

def print_csv_rows rows, csv_target_filename

	CSV.open(csv_target_filename, "a") do |csv|
		rows.each do |row_aux| 
			row = row_aux[1]
			#print "row=#{row}\n"
			#print "#{row["title"]},#{row["price"]},#{row["location"]},#{row["area"]},#{row["timestamp"]},#{row["link"]}\n"
			csv_row = [row["title"],row["price"],row["location"],row["area"],row["timestamp"],row["link"]]
			csv << csv_row
		end
	end
end

def parse_olx_article_html_page html_page
	title = clear_field_for_csv html_page.css('title').text
	#puts html_page.css('title').text.strip
	print "Title:#{title}"
	puts ""
	#File.open("tmp.htm", "wt") do |f|
	#	f.write html_page
	#end
	descriptions = html_page.css("meta[name=description]")
	description = ""
	descriptions.each do |desc| 
		description = clear_field_for_csv desc['content']
	end
	print "Description=#{description}\n"

	# <div class="offer-user__details ">
	users = html_page.css("div[class=\"offer-user__details \"] h4")
	users_since = html_page.css("div[class=\"offer-user__details \"] span")
	user = clear_field_for_csv users.text 
	user_since = clear_field_for_csv users_since.text
	#users.each do |u| 
	#	users = clear_field_for_csv u.text
	#end
	print "User=#{user}\n  since:#{user_since}\n"
end

def olx_parse_html_page page_file_name
	page = Nokogiri::HTML(open(page_file_name))   
	puts page.class   # => Nokogiri::HTML::Document

	puts page.css('title')
	puts "###"

	#divs = page.css("div[class=\"space rel\"]")

	rows = Hash.new(0)

	divs = page.css("tr[class=wrap]")


	divs.each do |div| 
		#puts div
		# Title
		print "===========================\n"
		#puts div.css("strong").text
		
		# Link
		div_link = ""
		div_title = "Unk"
		news_links = div.css("div[class=\"space rel\"]").css("a[href]")
		news_links.each do |link| 
		  #puts "#{link.text}\t#{link['href']}"
		  div_link = link['href'].strip
		  div_title = clear_field_for_csv link.text.strip
		end
		print "Title:#{div_title}\n"
		print "Link:#{div_link}\n"
		if div_title =="Unk" or div_title =="" or div_title == "Ver todos os anúncios »" or 
		   div_title == "Destacar anúncio" or
		   div_title == "Terrenos e Quintas"
			print "=== (!) Skipping invalid title:#{div_title}\n"
			next
		end
			
		
		# Location and Timestamp
		spans = div.css("p[class=lheight16]").css('span')
		location = ""
		timestamp = ""
		spans.each do |span| 
		  #puts "#{link.text}\t#{link['href']}"
		  print "...span=#{span}"
		  if location == ""
			location = clear_field_for_csv span.text.strip
		  else
			timestamp = clear_field_for_csv span.text.strip
		  end
		end
		print "Location:#{location}\n"
		print "timestamp:#{timestamp}\n"
		
		# Price
		price = div.css("p[class=price]").css('strong').text
		print "Price:#{price}\n"
		
		# Area
		areas = /(\d+|\d+\.\d+)(\s?m)/.match(div_title)
		if !areas.nil?
			print "areas=#{areas[0]}\n"
			area = areas[0]
		else
			area = 0
		end
		
		new_row = Hash.new(0)
		new_row["title"] = div_title
		new_row["link"] = div_link	
		new_row["location"] = location
		new_row["price"] = price
		new_row["timestamp"] = timestamp
		new_row["area"] = area
		
		rows[div_title] = new_row
	end

	print "### All rows #{rows}\n"

	# Export to .csv, remove "," from text

	# TODO: fetch pages from "links" and extract more data 
	#  - description, anunciante, ID do anúncio, fotos, etc
	rows.each do |row|	
		print "### Opening link #{row[1]["link"]} ...\n"
		page = Nokogiri::HTML(open(row[1]["link"]))
		parse_olx_article_html_page page
	end
	#print_csv_rows rows
	
	return rows
	
end

rows_all_pages = Array.new(3)

rows_all_pages[0] = olx_parse_html_page "G:\\TEMP\\Temp\\webdatarip\\olx.p1.htm" 
rows_all_pages[1] = olx_parse_html_page "G:\\TEMP\\Temp\\webdatarip\\olx.p2.htm" 
rows_all_pages[2] = olx_parse_html_page "G:\\TEMP\\Temp\\webdatarip\\olx.p3.htm" 

print "### All rows from ALL PAGES \n"
print "Title,Price,Location,Area,Time,URL\n"

def print_data_csv rows_all_pages, csv_target_filename

	
	print_csv_header csv_target_filename
	rows_all_pages.each do |rows|
		print_csv_rows rows, csv_target_filename
	end
	
end

#OpenSSL::X509::Store.set_default_paths
# set SSL_CERT_FILE=C:\Users\tagido\Downloads\cacert.pem
OpenSSL::X509::Store.add_file ("C:\\users\\tagido\\Downloads\\cacert.pem")
OpenSSL::X509::Store.add_file ("D:\\Program Files\\Ruby23-x64\\lib\\ruby\\site_ruby\\2.3.0\\rubygems\\ssl_certs\\GlobalSignRootCA.pem")

csv_target_filename = "data.csv"

print_data_csv rows_all_pages, csv_target_filename