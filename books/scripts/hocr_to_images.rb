# hocr_to_images.rb
#
#

require 'nokogiri'
require_relative "../../framework/scripts/framework_utils.rb"


def parse_and_convert_hocr hocr_file
	
	doc_str = ""
	
	#doc = File.open(hocr_file) { |f| doc_str=Nokogiri::XML(f) }
	
	@doc = Nokogiri::XML(File.open(hocr_file,'rb'))
	
	@doc.remove_namespaces!
	
	#puts "=== doc #{@doc}\n"
	
	divs = @doc.xpath('div')
	
	puts "=== parse_and_convert_hocr #{hocr_file}\n"
	
	puts "=== divs #{divs}\n"
	
	n_divs = 0
	
	image_file = "tmp"
	
	@doc.xpath('//body//div','class' => 'ocr_page').each do |thing|
		image_file_tmp = thing["title"]
		
		image_file = image_file_tmp.scan(/image \"(.*)\";/)[0][0]
		
		puts "image_file=#{image_file}\n"
		
		break
	end
	
	
	@doc.xpath('//body//div//div','class' => 'ocr_carea').each do |thing|
		#puts "ID   = " + thing.at_xpath('id')
		
		#<div class='ocr_carea' id='block_1_1' title="bbox 225 239 1223 622">
		
		puts "class = " + thing["class"] + " , id " + thing["id"] + " , title " + thing["title"]
		
		img_coordinates = thing["title"].scan(/bbox (\d*) (\d*) (\d*) (\d*)/)
		
		
		puts "n_divs=#{n_divs}\n"
		puts "img_coordinates=#{img_coordinates[0]}\n"
		
		img_start_x = img_coordinates[0][0]
		img_start_y = img_coordinates[0][1]
		img_end_x = img_coordinates[0][2]
		img_end_y = img_coordinates[0][3]
		
		image_crop image_file, "#{image_file}.crop_#{n_divs}.png", img_start_x, img_start_y, img_end_x, img_end_y
		
		n_divs = n_divs + 1
	end
	
	puts "+++\n\n"


end

def extract_images_from_hocr source_path

	puts "Extracting TXT files from #{source_path} ... \n\n"
	
	command = "dir \"#{source_path}\\page*.hocr\" /b /s /od"
	
	puts "cmd=#{command}"
		
	png_files= `#{command}`
	
	caps = png_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	#LANGUAGE="por"
	language="eng"
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
	   
	   parse_and_convert_hocr i[0]
  	 
	   index = index + 1 
	   
	   
	end

    # d:\Program Files\tesseract\tesseract.exe" page1-1.png -psm 3 --tessdata-dir "d:\Program Files\tesseract\tessdata" pdf -l por pdf.config
end

#TODO: break long vertical images in two halves
#TODO: try to discard very "thin" images (lines (?)) or join with other images
#TODO: display stats over converted images (aspect-ratio, ...)
#TODO: move code to library
#TODO: create a "paper_to_mobi" script

extract_images_from_hocr "."