require 'rubygems'
require 'nokogiri'  
require 'open-uri'
require 'json'
require 'CSV'
require 'OpenSSL'
require 'open-uri'

# http://ruby.bastardsbook.com/chapters/html-parsing/

# http://ruby.bastardsbook.com/chapters/mechanize/


def clear_field_for_csv text
	return text.strip.gsub(/,/,";").gsub(/\n|•|\r/," ")
end

def print_csv_header csv_target_filename
	CSV.open(csv_target_filename, "wb") do |csv|		
		csv << ["Title","Price","Location","Area","Time","URL","Description","user"]
	end
end

def print_csv_rows rows, csv_target_filename

	CSV.open(csv_target_filename, "a") do |csv|
		rows.each do |row_aux| 
			row = row_aux[1]
			#print "row=#{row}\n"
			#print "#{row["title"]},#{row["price"]},#{row["location"]},#{row["area"]},#{row["timestamp"]},#{row["link"]}\n"
			csv_row = [row["title"],row["price"],row["location"],row["area"],row["timestamp"],row["link"],row["Description"],row["user"]]
			csv << csv_row
		end
	end
end

def parse_olx_article_html_page html_page, row_to_update
	print "row_to_update=#{row_to_update}\n"
	title = clear_field_for_csv html_page.css('title').text
	#puts html_page.css('title').text.strip
	print "Title:#{title}"
	puts ""
	#File.open("tmp.htm", "wt") do |f|
	#	f.write html_page
	#end
	
	# TODO: fetch complete descritption for the article content (this one is truncated)
	descriptions = html_page.css("meta[name=description]")
	description = ""
	descriptions.each do |desc| 
		description = clear_field_for_csv desc['content']
	end
	print "Description=#{description}\n"
	row_to_update["Description"] = description
	
	# <div class="offer-user__details ">
	users = html_page.css("div[class=\"offer-user__details \"] h4")
	users_since = html_page.css("div[class=\"offer-user__details \"] span")
	user = clear_field_for_csv users.text 
	user_since = clear_field_for_csv users_since.text
	

	#users.each do |u| 
	#	users = clear_field_for_csv u.text
	#end
	print "User=#{user}\n  since:#{user_since}\n" 
	row_to_update["user"] = user
	row_to_update["user_since"] = user_since
end

def olx_parse_html_page page_file_name, local_file
	if local_file
		page = Nokogiri::HTML(open(page_file_name)) 
	else
		print "Downloading page #{page_file_name}\n"
		page = Nokogiri::HTML(open(page_file_name)) 
	end
	
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
		# TODO: some links point to Imovirtual, check , if possible parse both links
		print "### Opening link #{row[1]["link"]} ...\n"
		page = Nokogiri::HTML(open(row[1]["link"]))
		row[1] = parse_olx_article_html_page page, row[1]
	end
	#print_csv_rows rows
	
	return rows
	
end

def test_olx_local_files
	rows_all_pages = Array.new(3)

	rows_all_pages[0] = olx_parse_html_page "G:\\TEMP\\Temp\\webdatarip\\olx.p1.htm" , true
	rows_all_pages[1] = olx_parse_html_page "G:\\TEMP\\Temp\\webdatarip\\olx.p2.htm" , true
	rows_all_pages[2] = olx_parse_html_page "G:\\TEMP\\Temp\\webdatarip\\olx.p3.htm" , true

	print "### All rows from ALL PAGES \n"
	print "Title,Price,Location,Area,Time,URL\n"
	csv_target_filename = "data.csv"

	print_data_csv rows_all_pages, csv_target_filename
end

def print_data_csv rows_all_pages, csv_target_filename

	
	print_csv_header csv_target_filename
	rows_all_pages.each do |rows|
		print_csv_rows rows, csv_target_filename
	end
	
end

def open_query_by_URL query_url, page_no
	olx_parse_html_page "#{query_url}&page=#{page_no}" , false
end


# https://ruby-doc.org/core-2.2.0/Array.html
#
#

def open_olx_query
	#query_url = "https://www.olx.pt/imoveis/terrenos-quintas/agualvacacem/?search%5Bfilter_float_price%3Ato%5D=25000"
	query_url = "https://www.olx.pt/imoveis/terrenos-quintas/agualvacacem/?search%5Bfilter_float_price%3Ato%5D=25000&search%5Bdist%5D=15"

	rows_all_pages = Array.new(0)

	page_no = 1
	last_page_found = false
	while not last_page_found
		begin
			new_page = open_query_by_URL query_url, page_no
			rows_all_pages << new_page
			page_no = page_no + 1
		#rescue
		#	last_page_found = true
		end
		if page_no > 3
			# TODO: auto-detect number of pages
			last_page_found = true
		end
	end
	
	print "### All rows from ALL PAGES \n"
	print "Title,Price,Location,Area,Time,URL\n"
	
	# TODO: post-filter uninteresting values
	# price < 5000
	# ... aluga / arrenda
	# reformatar area
	
	csv_target_filename = "olx_agualva.data.csv"

	print_data_csv rows_all_pages, csv_target_filename	
end

def test_olx_query
	open_olx_query
end

#OpenSSL::X509::Store.set_default_paths
# set SSL_CERT_FILE=C:\Users\tagido\Downloads\cacert.pem

# website_data_ripper.rb:201:in `<main>': undefine d method `add_file' for OpenSSL::X509::Store:Class (NoMethodError)
#  - https://bugs.ruby-lang.org/issues/12687
#
print "#{OpenSSL}\n"
print "#{OpenSSL::X509}\n"
print "#{OpenSSL::X509::Store}\n"
#OpenSSL::X509::DEFAULT_CERT_DIR = 
print "DEFAULT_CERT_DIR=#{OpenSSL::X509::DEFAULT_CERT_DIR}\n"

store = OpenSSL::X509::Store.new
store.add_file ("C:\\users\\tagido\\Downloads\\cacert.pem")
store.add_file ("D:\\Program Files\\Ruby23-x64\\lib\\ruby\\site_ruby\\2.3.0\\rubygems\\ssl_certs\\GlobalSignRootCA.pem")
#OpenSSL::X509::Store.add_file ("C:\\users\\tagido\\Downloads\\cacert.pem")
#OpenSSL::X509::Store.add_file ("D:\\Program Files\\Ruby23-x64\\lib\\ruby\\site_ruby\\2.3.0\\rubygems\\ssl_certs\\GlobalSignRootCA.pem")

#test_olx_local_files
test_olx_query