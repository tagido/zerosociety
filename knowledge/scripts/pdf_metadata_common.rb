# 	pdf_metadata_common.rb
#   ---------------------------
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


# Uses: https://github.com/yob/pdf-reader
 
 require 'pdf-reader'
 
 
 def print_pdf_info_elements pdf_info
	print "PDF Info elements =\n"
	
	if !(pdf_info.nil?) then 
		print "PDF Title =#{pdf_info[:Title]}\n\n"
	
		pdf_info.each do |i|
			print "#{i}\n" 
		end
	
	end
 end
 
 class PdfPaperMetadata 
 
  attr_accessor :title, :year, :filename, :author
  
  def initialize (filename)
	@filename=filename
	@year=-1
	@title="UNK"
	@author="UNK"
  end
 
  def set_year year
	@year=year
  end
  
  def set_title_from_pdf_metadata title
	if (!title.nil?) and !(title.start_with?("Microsoft Word - ")) then
		@title=title.strip
	end
  end
  
  def set_title_from_pdf_first_page title
	if (@title == "UNK" or  @title.length <=20) and (!title.nil?) then
	@title=title.strip
	end
  end
  
  def clean_title
	if @title.nil? then
		return
	end
  
  
	# is title too long ?
	if  @title.length >=100 then
	    @title=@title.slice(0, 100)
	end
	
	#remove "strange" chars - \u00A0 u00A4
	#@title=@title.encode("Windows-1252","UTF-8")
	@title.gsub!(/\u00A0/, ' ')
	@title.gsub!(/\t/, ' ')

	
	#remove leading non-letter chars
	@title = @title.gsub(/\A[\d_\W]+|[\d_\W]+\Z/, '')

	#looks like a long unix filename ?
	
	# looks like a URL ?
	
	#remove leading University of ...
	
	# remove doi:..., arXiv:1404.7828 ...
	
	end
 
   def set_author_from_pdf_metadata author
	if !author.nil?
		@author=author.strip
	end
	
	# TODO: remove empty authors
	
   end
 
  def get_metadata_from_pdf_info_elements pdf_info
	print "PDF Info elements =\n"
	
	if !(pdf_info.nil?) then 
		print "PDF Title =#{pdf_info[:Title]}\n\n"
	
		set_title_from_pdf_metadata pdf_info[:Title]
		set_author_from_pdf_metadata pdf_info[:Author]
	
		pdf_info.each do |i|
			print "#{i}\n" 
		end
	
	end
  end
 
  # TODO: parse DOIs [:"WPS-ARTICLEDOI", "10.1111/glob.12099"], 
  #    [:"WPS-JOURNALDOI", "10.1111/(ISSN)1471-0374"], 
 
  # TODO: classifier : paper, receipt, ..., book
  
  def get_new_filename
  
	if @year.to_i > 1000
		new_year = @year
	else
		new_year = "0000"
	end
  
	new_filename = "#{new_year}_#{@author}_#{@title}.pdf"
	
	# TODO: remove invalid filename chars
	
	# TODO: add trailing numbers if two files generate the same name
	
	return new_filename
  end
 
  def dump
	print "File: #{@filename}\n"
	print "Title: #{@title}\n"
	print "Author: #{@author}\n"
	print "Year: #{@year}\n"
	print "SuggestedNewName: #{get_new_filename}\n"
	print "\n"
  end
 
 end
 
 def print_pdf_info pdf_file
 
	paper_metadata = PdfPaperMetadata.new pdf_file
 
	begin
 
    reader = PDF::Reader.new(pdf_file)
	print "### PDF file #{pdf_file}\n"
	print "PDF Version =#{reader.pdf_version}\n"
    print "PDF Info =#{reader.info}\n"
	
	#print_pdf_info_elements reader.info
	paper_metadata.get_metadata_from_pdf_info_elements reader.info
	
    #print "PDF Metadata =#{reader.metadata}\n"
    print "PDF PageCount =#{reader.page_count}\n\n"
	
	page_no=1
	
	all_dates = Array.new
	
	reader.pages.each do |page|
	  print "\n###--- Page No.=#{page_no}" #" , #{page.text.inspect.strip[0..100]}"
	  
	  # TODO: skip most pages for file with many pages
	  
	  dates = page.text.inspect.strip.scan(/\((\d\d\d\d)\)/)
	  if dates.size == 0 then
	    # try other format
		dates = page.text.inspect.strip.scan(/(\d\d\d\d)/)
	  end
	  
	  print "###--- dates #{dates.size}\n"
	  
	  if dates.size > 0 then
		all_dates << dates
	  end
	  
      #puts page.fonts
      #puts page.text
      #puts page.raw_content
	  
	  if page_no==1 then
		possible_title = page.text.inspect.strip.gsub(/\\n/, " ").gsub(/\s+/," ")[0..200]
	    print "possible title: #{possible_title} \n"
		paper_metadata.set_title_from_pdf_first_page possible_title
	  end 
	  
	  page_no = page_no + 1
    end

	all_dates_sorted = all_dates.flatten.sort.reverse
	if all_dates_sorted.size > 0 then
	   # TODO: filter out bogus years greater than the current year
	   
	   # Time.current.year
	   print "### filtering dates > #{Time.now.year}\n"
	   
	   all_dates_sorted.reject! {|x| x.to_i > Time.now.year}
	   
	   possible_paper_year = all_dates_sorted[0]
	else 
	   possible_paper_year = -1
	end
	
	print "###--- all dates #{all_dates_sorted}\n"
	print "###--- possible_paper_year #{possible_paper_year}\n"
	
	paper_metadata.set_year possible_paper_year
	
	rescue => exception
		print "###--- unhandled exception reading PDF file #{pdf_file}\n"
		print "###--- #{exception.backtrace} \n"
	end
	
	paper_metadata.clean_title
	paper_metadata.dump
	
	return paper_metadata
end

def check_for_pdf_files pdf_path

	puts "Checking for pdf files ..."
	puts "-------------\n\n"

	pdf_files= `dir #{pdf_path}\\*.pdf\ /b /s /a-d`

	caps = pdf_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	caps.each do |i|
		print_pdf_info i[0]	 
	end

end

#print_pdf_info ARGV[0]

check_for_pdf_files ARGV[0]

# Sugerir novo nome para o ficheiro (autor-titulo) ou data_autor_titulo ...
#  - ver metatada, primeira pagina, cabecalhos/rodapes
# Mover ficheiro para localizacao adequada
#  - Inbox de artigos cientificos
#    - subcategorias
#  - Inbox de livros
#  - Faturas / Comprovativos
# Exportar refs
#  - ir ao fim do ficheiro e ver se tem refs, exporta-las para txt e depois para .bib
# Indexar pdfs
# Identificar duplicados (?)
# Extrair grafo entre artigos que se referenciam

