#
# process_kindle_clippings2xml.rb
# ===============================
# Convert "Kindle e-Reader" notes to other formats
#
# Currently supported input formats:
# - "My Clippings.txt" file (from a Kindle e-Reader)
#    ( TODO: support multiple device locales (PT-pt hardcoded for now, for dates)  )
#
# Currently supported output formats:
# - ".psv" (pipe-separated values)
# - ".mm" Mind-Map
#
#   Copyright (C) 2016 Pedro Mendes da Silva 
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
#

require 'time'
require_relative "../../framework/scripts/framework_utils.rb"



#
# File converters
#

def convert_number_locale_from_PT_to_US number_str
	
	if number_str.nil?
		return number_str
	end
	
	#puts "original: #{number_str}\n"
	
	number_str_without_commas = number_str.delete(".")
	
	number_str_without_commas.gsub! ',', '.' 
	
	#puts "conv'd: #{number_str_without_commas}\n"
	
	return number_str_without_commas
				
end

def convert_string_to_utf8_quoted_printable string, add_prefix

	if add_prefix
		string.delete!("?")
		string.delete!("\n")
	end

	new_string = [string].pack('M').chomp("\n")
	
	if add_prefix
		new_string.chomp!("=")
		#new_string.delete!("\n")
		new_string = "=?utf-8?Q?"+new_string+"?="
	end
	
	return new_string
end

def sanitize_filename(filename)
  filename.strip do |name|
   # NOTE: File.basename doesn't work right with Windows paths on Unix
   # get only the filename, not the whole path
   name.gsub!(/^.*(\\|\/)/, '')

   # Strip out the non-ascii character
   name.gsub!(/[^0-9A-Za-z.\-]/, '_')
  end
  
  return filename.gsub(/[^0-9A-Za-z.\-]/, '_')
end

def kindle_write_mind_map book_title, groupped_entries, target_dir

# TODO: refactor mind-map support to library

	target_file2 = sanitize_filename(book_title) + ".mm"

	target_file = "#{target_dir}\\Kindle notes for #{target_file2}"
	

	print "Writing MindMap #{target_file} ...\n"
	
	begin
	
	xml_txt_encoder = Encoding::Converter.new("UTF-8", "ISO-8859-1", :xml => :text)
	xml_attr_encoder = Encoding::Converter.new("UTF-8", "ISO-8859-1", :xml => :attr)
	
	book_title_xml = xml_txt_encoder.convert(book_title).dump.gsub!(/\\x(\w\w)/, '&#x\1;')
	
	if (!book_title_xml)
		book_title_xml = "\"Book notes\""
	end
	
	
	#note_text_xml = xml_txt_encoder.convert(note_text).dump
	
	#book_title_xml = book_title.encode(:xml => :text, "ISO-8859-1")
	
	xml_file_string = ""
	xml_file_string = xml_file_string + "<map version=\"docear 1.1\" >\n"
	xml_file_string = xml_file_string + "<node TEXT=#{book_title_xml} FOLDED=\"false\" >\n"
	
	groupped_entries.each do |entry|
		# Parse fields
		#.gsub(/"/,'')

		note_text = entry[1]
		book_title = entry[0]
		note_text_xml = xml_attr_encoder.convert(note_text).dump.gsub(/\\x(\w\w)/, '&#x\1;').gsub(/\\"/,'')
		
		if note_text_xml
		
			xml_file_string = xml_file_string + "	<node TEXT=#{note_text_xml} FOLDED=\"false\" >\n"
			xml_file_string = xml_file_string + "	</node>\n"
			
		end
	  end

	xml_file_string = xml_file_string + "</node>\n"
	xml_file_string = xml_file_string + "</map>\n"
	
	File.open(target_file, 'w') { 
			|file| file.write(xml_file_string)
	}
	
	rescue
		print "... FAILED\n"
	end
	
end

def kindle_convert_TXT_2_XML entries, target_dir
	
	puts "Converting TXT to XML ... \n"
	
	target_file = "#{target_dir}\\kindle.xml.csv"
	
	note_list = Array.new 
	
	index = 0
	
	entries.each do |entry|
			
	
		# Parse fields
		
		note_text = entry[3]
		book_title = entry[0]
				
		new_entry = Array.new
		new_entry.push(book_title)
		new_entry.push(note_text)
		
		puts "new_entry=#{new_entry}\n"
				
		note_list.push( new_entry )
		
		# Write CSV file
		
		#
		#xml_file_string = "#{book_title}|#{note_text}\n"
		#
		#File.open(target_file, 'a') { 
		#	|file| file.write(xml_file_string)
		#}
		
		index = index + 1
	end

	# Convert to one mind-map per book
	#
	
	grouped_list = note_list.group_by { |i| i[0] }
	
	
	puts "nl: \n #{note_list}\n"
	
	puts "gr: \n #{grouped_list}\n"

	xml_file_string = ""
	
	grouped_list.each do |key, groupped_entries|
			
	  groupped_entries.each do |entry|
		# Parse fields
		
		note_text = entry[1]
		book_title = entry[0]
		xml_file_string = xml_file_string + "#{book_title}|#{note_text}\n"
		
		
	  end
	  
	  kindle_write_mind_map key, groupped_entries, target_dir
		
	end
	
	# Write ".psv file"
	
	File.open(target_file, 'w') { 
			|file| file.write(xml_file_string)
	}
		
	
	
end


def convert_month_PT_to_number month_str

	case month_str
	when "Janeiro"
	    1
	when "Fevereiro"
	    2
	when "Março"
	    3
	when "Abril"
	    4
	when "Maio"
	    5
	when "Junho"
	    6
	when "Julho"
	    7
	when "Agosto"
	    8
	when "Setembro"
	    9
	when "Outubro"
	    10
	when "Novembro"
	    11
	when "Dezembro"
	    12
	else
	  1
	end

end

#
# File handlers
#


def kindle_get_entries_from_txt_file kindle_file

	entries =  `type \"#{kindle_file}\"`
	
	# Format:
	# Line 1: Book title
	# Line 2: Book position and note date and note type (destaque,marcador,nota)
	# Line 3: empty ?
	# Line 4: note text
	# Line 5: separator (==========)
	
	entry_list = entries.force_encoding('utf-8').scan(/(.*?)\n(.*?)\n(.*?)\n(.*?)\n(.*?)==========\n/)
	
	#\;(.*)\;(.*)\;(.*)\;(.*)\;(.*)
	
	puts "entry_list: \\n\n #{entry_list}"
	
	return entry_list
end


# TODO: automate dependencies and directories (currently hardcoded)
DOWNLOADS_PATH="C:\\Users\\tagido\\Downloads"
KINDLE_CLIPPINGS_PATH="#{DOWNLOADS_PATH}\\My Clippings.txt"

puts "process_kindle_clippings2xml.rb - ..."
puts "-------------\n\n"

entries = kindle_get_entries_from_txt_file KINDLE_CLIPPINGS_PATH

time = Time.now.getutc
#time2 = time.to_s.delete ': '
time2 = "_tmp"


TARGET_PATH="#{KINDLE_CLIPPINGS_PATH}.exported\\kindle_clippings#{time2}"
print "mkdir \"#{TARGET_PATH}\"\n"
system "mkdir \"#{TARGET_PATH}\""

kindle_convert_TXT_2_XML entries, TARGET_PATH

# TODO: add conversion to PPTX