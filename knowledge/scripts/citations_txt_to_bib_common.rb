#
#   citations_txt_to_bib.rb
#   =================================
#   Converts a txt file with a list of citations/refs and converts them to .bib format
#
# freecite API:
# -------------
# http://freecite.library.brown.edu/welcome/api_instructions
#
#
#   Copyright (C) 2018 Pedro Mendes da Silva 
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

require 'net/http'
require 'bibtex'
require 'nokogiri'

# https://github.com/inukshuk/bibtex-ruby
# https://github.com/andriusvelykis/bibtex-ruby
# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html


def convert_freecite_to_bibtext freecite_xml_str, ref_index

	@doc = Nokogiri::XML(freecite_xml_str)
	
	@doc.remove_namespaces!
	
	book = nil
	
	@doc.xpath('//citations//citation','valid' => 'true').each do |thing|
		#image_file_tmp = thing["title"]
		
		puts "thing=#{thing}\n"
		
		book = BibTeX::Entry.new
		book.type = :article
		#if thing.at_css('author')
		#	book.key = thing.at_css('author').content
		#end
		
		book.key = "ref#{ref_index}"
		
		if (!thing.at_css('title').nil?) and (!thing.at_css('title').content.nil?)		
			book.title = thing.at_css('title').content
		else
			book.title = "Unk"
		end
		
		tmp = thing.at_css('year')
		if tmp		
			book.year = tmp.content 
		end
		
		tmp = thing.at_css('journal')
		if tmp		
			book.publisher = tmp.content 
		end
		
		tmp = thing.at_css('location')
		if tmp		
			book.address = tmp.content
		end

		tmp = thing.at_css('booktitle')
		if tmp		
			book.booktitle = tmp.content 
		end

		
		authors_str = ""
		#puts "authors.encoding=#{authors_str.encoding}\n"
		
		thing.xpath('//authors//author').each do |author|
		
			if !(authors_str=="")
				authors_str = authors_str + " and "
			end
			
			authors_str = authors_str + author.content
			
			# puts "author.content.encoding=#{author.content.encoding}\n"
		end
		
		book.author = authors_str #.encode("ISO-8859-1") 
		
		break
	end

	puts "book=#{book}\n"
	
	return book

end

def freecite_get_citation plain_text, ref_index

	xml_citations = nil

	Net::HTTP.start('freecite.library.brown.edu', 80) do |http|
	  response = http.post('/citations/create',
		"citation=#{plain_text}",
		'Accept' => 'text/xml')

	  puts "Code: #{response.code}"
	  puts "Message: #{response.message}"
	  puts "Body:\n #{response.body}"
	  
	  xml_citations = response.body
	end

	return convert_freecite_to_bibtext(xml_citations,ref_index)
	
end

def string_starts_with_capital_letter string
	print "### string_starts: '#{string[0][0]}' ... \n"
	return /[[:upper:]]/.match(string[0][0])
end

# TODO: reject empty author and author starting with lowercase
# A(2003) => year

def convert_citations_from_plain_txt_to_bib plain_text_file

	bib = BibTeX::Bibliography.new(:parse_names => false)

	#TODO: abrir ficheiro em UTF-8, parece estar a abrir em ascii
	
	line_num=0
	File.open(plain_text_file).each do |line|
		print "#{line_num += 1} : #{line}"
		
		begin
			book = freecite_get_citation line.encode("UTF-8"), line_num
		    if !book.nil? and book.title != "Unk" and string_starts_with_capital_letter(book.title)
				bib << book
			else
				print "### (!) Skipping invalid ref: #{line}\n"
			end
		rescue => exception
			print "### !!! Somenthing went wrong with ref \n#{exception.backtrace} \n"
		end
	end

	bib.save_to("#{plain_text_file}.bib")
end

#Net::HTTP.start('freecite.library.brown.edu', 80) do |http|
#  response = http.post('/citations/create',
#    'citation=A. Bookstein and S. T. Klein,  \
#    Detecting content-bearing words by serial clustering,  \
#    Proceedings of the Nineteenth Annual International ACM SIGIR Conference \
#    on Research and Development in Information Retrieval,   \
#    pp. 319327,   1995.',
#    'Accept' => 'text/xml')
#
#  puts "Code: #{response.code}"
#  puts "Message: #{response.message}"
#  puts "Body:\n #{response.body}"
#end

#convert_citations_from_plain_txt_to_bib ARGV[0]



