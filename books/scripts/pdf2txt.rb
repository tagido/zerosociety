#
# pdf2txt.rb
# ==========
# Extracts text from pdf files without text resources (performs OCR with TESSERACT for this purpose)
# and converts it to some useful text formats
#
# Copyright (C) 2016 Pedro Mendes da Silva
# 
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

require_relative "../../framework/scripts/framework_utils.rb"





#
# File converters
#




def create_target_dir target_dir
	print "mkdir \"#{target_dir}\"  \n\n"
	system "mkdir \"#{target_dir}\""
	
	system "mkdir \"#{target_dir}\"\\png"
	system "mkdir \"#{target_dir}\"\\txt"
end

def extract_png_from_pdf source_path, target_dir
	puts "Extracting PNG files from #{source_path} ... \n\n"
	
	page_index = 1
	result = true
	
	while result == true do
	
	# -density 300 
		command = "\"#{IMAGEMAGICK_PATH}\\magick.exe\" -density 300  \"#{source_path}\"[#{page_index}] \"#{target_dir}\\png\\page#{page_index}.png\""

		puts "### Page #{page_index} - Executing: #{command}"
		result = system command
		
		page_index = page_index + 1
	end
		
end

def extract_txt_from_png source_path

	puts "Extracting TXT files from #{source_path} ... \n\n"
		
	png_files= `dir #{source_path}\\png\\*.png\ /b /s /od`
	
	caps = png_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
	  
	  command = "\"#{OCR_TESSERACT_PATH}tesseract.exe\" \"#{i[0]}\" #{source_path}\\txt\\page#{index} -psm 3 --tessdata-dir \"#{OCR_TESSERACT_PATH}tessdata\" -l por \"#{OCR_TESSERACT_PATH}tessdata\\pdf.config"
	  
	  puts "command=#{command}\n\n"
	  
	  system command
	 
	  index = index + 1 
	end

    # d:\Program Files\tesseract\tesseract.exe" page1-1.png -psm 3 --tessdata-dir "d:\Program Files\tesseract\tessdata" pdf -l por pdf.config
end


def concat_extracted_txt_files source_path

	puts "Extracting TXT single file from #{source_path} ... \n\n"
	
	txt_files= `dir #{source_path}\\txt\\*.txt\ /b /s /od`
	
	caps = txt_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	command = "copy "
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
 
	  
	  if index == 0
		command = command + "\"#{i[0]}\""
	  else
		command = command + "+\"#{i[0]}\""
	  end
	  
	  
	  index = index + 1 
	end

	command = command + " \"#{source_path}\\full_text.txt\""
	puts "command=#{command}\n\n"
	system command
	
end


def concat_extracted_hocr_files source_path

	puts "Extracting hocr single file from #{source_path} ... \n\n"
	
	txt_files= `dir #{source_path}\\txt\\*.hocr\ /b /s /od`
	
	caps = txt_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	command = "copy "
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
	  
	  if index == 0
		command = command + "\"#{i[0]}\""
	  else
		command = command + "+\"#{i[0]}\""
	  end
	  
	  system "copy \"#{i[0]}\" \"#{i[0]}.xhtml\""
	  
	  index = index + 1 
	end

	command = command + " \"#{source_path}\\full_text.xhtml\""
	puts "command=#{command}\n\n"
	system command
	
end



def concat_extracted_pdf_files source_path

	puts "Extracting TXT single file from #{source_path} ... \n\n"
	
	txt_files= `dir #{source_path}\\txt\\*.pdf\ /b /s /od`
	
	caps = txt_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	#command = "\"#{IMAGEMAGICK_PATH}\\magick.exe\" -adjoin "
	
	command = "\"#{GS_PATH}gswin32c\" -q -sPAPERSIZE=a4 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=\"#{source_path}\\full_text.pdf\""
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
 	  
		command = command + " \"#{i[0]}\""
	  	  
	  index = index + 1 
	end

	#command = command + " \"#{source_path}\\full_text.pdf\""
	puts "command=#{command}\n\n"
	system command
	
	
	
	#"pdf2txt.dir.PAGE2\txt\page2.pdf pdf2txt.dir.PAGE2\txt\page3.pdf
	
end


def convert_pdf_2_txt source_path

	time = Time.now.getutc
	time2 = time.to_s.delete ': '

	time2 = "#{source_path}"

	target_dir = "#{TARGET_PATH}pdf2txt.dir.#{time2}"

	create_target_dir target_dir

	extract_png_from_pdf source_path, target_dir

	# TODO: apply an optional "demultiplexer" filter to split the page in 2 or more
	
	extract_txt_from_png target_dir

	concat_extracted_txt_files target_dir
	
	# TODO: build an EPUB with the extracted HOCR files
	concat_extracted_hocr_files target_dir
	
	#concat_extracted_pdf_files TARGET_DIR	
	
end

def convert_multiple_pdf_2_txt

	puts "#### Extracting Multiple PDF files in the current directory  ... \n"
	puts "#### ... \n\n"
	puts "#### ... \n\n"
	
	pdf_files= `dir *.pdf /b /od`
	
	caps = pdf_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
 	  
	   convert_pdf_2_txt i[0]
	  	  
	   index = index + 1 
	end
	
end


# TODO: automate dependencies (currently hardcoded)
OCR_TESSERACT_PATH="D:\\Program Files\\tesseract\\"
#IMAGEMAGICK_PATH="D:\\Program Files\\ImageMagick-7.0.2-Q16\\"
GS_PATH="D:\\Program Files (x86)\\gs\\gs9.16\\bin\\"
SOURCE_PATH=ARGV[0]
TARGET_PATH="G:.\\"

time = Time.now.getutc
time2 = time.to_s.delete ': '

time2 = "#{SOURCE_PATH}"
TARGET_DIR="#{TARGET_PATH}pdf2txt.dir.#{time2}"

# TODO: correr o magick em blocos (quando são ficheiros muito grandes, encrava)


puts "pdf2txt.rb - ..."
puts "-------------\n\n"

if (SOURCE_PATH == "all")
	convert_multiple_pdf_2_txt
else
	convert_pdf_2_txt SOURCE_PATH
end