#
#   books_txt_to_bib.rb
#   =================================
#   Converts a txt file with a list of citations/refs and converts them to .bib format
#
# Openlibrary.org
# -------------
# 
#
#   isbnsearch.org
#   https://isbnsearch.org/search?s=Designing+Social+Interfaces+%2C+Christian+Crumlish
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
require 'active_support'
require 'openlibrary'

# https://github.com/inukshuk/bibtex-ruby
# https://github.com/andriusvelykis/bibtex-ruby
# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html


def convert_plain_text_to_bibtext plain_text_str, ref_index
	
	book = nil
			
	book = BibTeX::Entry.new
	book.type = :book
	
	client = Openlibrary::Client.new
	
	title = plain_text_str.split(",")[0]
	if title.nil?
		title = plain_text_str
	end
	
	results = client.search(title)
	
	if (!results[0].nil?) then   
	
			
		puts "thing=#{results[0]}\n"

		#if thing.at_css('author')
		#	book.key = thing.at_css('author').content
		#end
		
		book.key = "ref#{ref_index}"
		
		if (!results[0].title.nil?)		
			book.title = results[0].title
		else
			book.title = "Unk"
		end
		
		#book.isbn = results[0].isbn
		if (!results[0].isbn.nil?)
			print "isbn=#{results[0].isbn}\n"
			book.isbn = results[0].isbn[0]
		else
			print "NO isbn found\n"
		end
		
		if (!results[0].author_name.nil?)
			print "author_name=#{results[0].author_name}\n"
			tmp_author = results[0].author_name.join(" and ")
			if (!results[0].contributor.nil?)
				tmp_author = tmp_author + " and " +results[0].contributor.join(" and ")
			end
			book.author = tmp_author
		else
			print "NO author found\n"
		end
		
		if (!results[0].first_publish_year.nil?)
			print "date=#{results[0].first_publish_year}\n"
			book.date = results[0].first_publish_year
		else
			print "NO date found\n"
		end
		
		if (!results[0].publisher.nil?)
			print "date=#{results[0].publisher}\n"
			book.publisher = results[0].publisher.join(" and ")
		else
			print "NO publisher found\n"
		end
		
		book.comment = "full data from openlibrary: #{results[0]}".encode("UTF-8")
		
	else
		# Could not find an ISBN,  dump line to .bib anyway
		book.title = plain_text_str		
	end	

	puts "book=#{book}\n"
	
	return book

end


def convert_citations_from_plain_txt_to_bib plain_text_file

	bib = BibTeX::Bibliography.new(:parse_names => false)

	#TODO: abrir ficheiro em UTF-8, parece estar a abrir em ascii
	
	line_num=0
	File.open(plain_text_file).each do |line|
		print "#{line_num += 1} : #{line}"
		
		book = convert_plain_text_to_bibtext line.encode("UTF-8"), line_num
		
		bib << book
	end

	bib.save_to("#{plain_text_file}.bib")
end


convert_citations_from_plain_txt_to_bib ARGV[0]



