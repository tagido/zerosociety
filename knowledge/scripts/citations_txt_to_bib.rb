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
require_relative "./citations_txt_to_bib_common.rb"

require 'net/http'
require 'bibtex'
require 'nokogiri'

# https://github.com/inukshuk/bibtex-ruby
# https://github.com/andriusvelykis/bibtex-ruby
# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html




convert_citations_from_plain_txt_to_bib ARGV[0]



