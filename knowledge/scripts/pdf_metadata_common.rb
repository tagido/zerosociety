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
 require_relative "../../framework/scripts/framework_utils.rb"
 require 'Timeout'
 
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
	@n_skipped_first_page_lines = 0
  end
 
  def set_year year
	@year=year
  end
  
  def set_title_from_pdf_metadata title
	if (!title.nil?) and 
	   !(title.start_with?("Microsoft Word - ")) and  
	   !(title.start_with?("PII: ")) and 	   
	   !title.start_with?("pnas") then
		@title=title.strip
	end
  end
  
  def set_title_from_pdf_first_page title, lines
	
	begin
  
  		print "\nx0xx @n_skipped_first_page_lines=#{@n_skipped_first_page_lines} ...\n"
		print "lines[@n_skipped_first_page_lines]=#{lines[@n_skipped_first_page_lines]}\n"
		b = lines[@n_skipped_first_page_lines].include? "New Political Economy"
		print "#{b}\n"

		while !lines.nil? and 
		  (lines[@n_skipped_first_page_lines].include? "http://" or 
		   lines[@n_skipped_first_page_lines].include? "https://" or
		   lines[@n_skipped_first_page_lines].include? "doi:" or
		   lines[@n_skipped_first_page_lines].include? "New Political Economy" or
		   lines[@n_skipped_first_page_lines].include? "personal copy" or
		   lines[@n_skipped_first_page_lines].include? "Journal" or	  
		   lines[@n_skipped_first_page_lines].include? "JOURNAL" or	   		   
		   lines[@n_skipped_first_page_lines].include? "www.elsevier.com" or
		   lines[@n_skipped_first_page_lines].include? "SciVerse ScienceDirect" or	   
		   lines[@n_skipped_first_page_lines].include? "week ending" or 
		   lines[@n_skipped_first_page_lines].include? "\"REVIEW" or
		   lines[@n_skipped_first_page_lines].include? "Proceedings" or
		   lines[@n_skipped_first_page_lines].include? "June" or # TODO: dates	  
		   lines[@n_skipped_first_page_lines].include? "PHYSICAL REVIEW LETTERS") 
			
			@n_skipped_first_page_lines = @n_skipped_first_page_lines + 1
			 		
			print "\nx1xx @n_skipped_first_page_lines=#{@n_skipped_first_page_lines} ...\n"

		end
		new_title=lines[0 + @n_skipped_first_page_lines].strip 
		
		# Concat next line if it does not look like an author
		if lines[1 + @n_skipped_first_page_lines].strip.count('.') == 0 and lines[1 + @n_skipped_first_page_lines].strip.count(',') == 0
		 new_title=new_title+lines[1 + @n_skipped_first_page_lines].strip
		 @n_skipped_first_page_lines = @n_skipped_first_page_lines + 1
		end
		
		print "\nxxx @n_skipped_first_page_lines=#{@n_skipped_first_page_lines} ...\n"
	
		if (@title == "UNK" or  @title.length <=20) and (!new_title.nil?) then
			@title=new_title.strip
		end		
	
	
	rescue => exception
		print "!!! Somenthing went wrong with title\n#{exception.backtrace} \n"
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
	
	# TODO: replace multiple consecutive spaces
	
	#remove "strange" chars - \u00A0 u00A4
	#@title=@title.encode("Windows-1252","UTF-8")
	begin 
		@title.gsub!(/\u00A0/, ' ')
		@title.gsub!(/\t/, ' ')
	
		#remove leading non-letter chars
		@title = @title.gsub(/\A[\d_\W]+|[\d_\W]+\Z/, '')

		#looks like a long unix filename ?
		
		# looks like a URL ?
		
		#remove leading University of ...
		
		# remove doi:..., arXiv:1404.7828 ...
	rescue => exception
		print "!!! Somenthing went wrong with title=#{@title} \n#{exception.backtrace} \n"
	end
   end
 
   def clean_author
	if @author.nil? then
		return
	end
	
	# is author too long ?
	if  @author.length >=25 then
	    @author=@author.slice(0, 25)
	end
	
	# remove empty authors
	if  @author.length == 0 then
		@author="UNK"
	end
	
	# TODO: remove numbers
	
	# TODO: remove known prefixes: "Author(s):"
	
	# TODO: remove email addresses eg: "joe@diskserver.castanet.com Joe Pickert"
	
	# replace tabs
	@author.gsub!(/\t/,' ')
   end
 
   def set_author_from_pdf_metadata author
	if !author.nil? and author.length > 0 
		@author=author.strip
	end
   end
 
  def set_author_from_pdf_first_page lines
  
	if (@author == "UNK") and (!lines.nil?) then
	
		print "@n_skipped_first_page_lines=#{@n_skipped_first_page_lines} ...\n"
	
		@n_skipped_first_page_lines = @n_skipped_first_page_lines + 1
	
	    new_author = lines[@n_skipped_first_page_lines].strip.gsub(/ /,'')
		while (new_author.include? "Article" or 
				new_author.include? "author" or 
				new_author.include? "DOI:" or 
				new_author.include? "CITATIONS" or new_author.length < 9)
			@n_skipped_first_page_lines = @n_skipped_first_page_lines + 1
			new_author = lines[@n_skipped_first_page_lines].strip.gsub(/ /,'')
		end
		
		# restore spaces
		new_author = lines[@n_skipped_first_page_lines].gsub(/[\s\b\v]+/, " ").strip
		
		@author=new_author
	end
  
	# truncate very long names
  
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
  
    if @title.nil? or @title.length==0 or  @title=="UNK"
		@title=File.basename @filename
	end
  
	new_filename = "#{new_year}_#{@author}_#{@title}.pdf"
	
	# TODO: handle null @title => use original filename without extension
	
	# TODO: add trailing numbers if two files generate the same name
	new_filename = sanitize_filename(new_filename)
	
	return new_filename
  end
  
  def move_and_rename target_path
	new_filename = target_path + "\\" +get_new_filename
	print "### Moving #{@filename} to #{new_filename} ...\n"
	copy_and_rename_file_to_target_dir @filename,get_new_filename, target_path
  end
 
  def dump
  status = Timeout::timeout(5) {
	# Something that should be interrupted if it takes more than 5 seconds...

	print "File: #{@filename}\n"
	print "Title: #{@title}\n"
	print "Author: #{@author}\n"
	print "Year: #{@year}\n"
	print "SuggestedNewName: #{get_new_filename}\n"
	print "\n"
	}
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
	
	n_skipped_pages_at_the_begining = 0
	
	reader.pages.each do |page|
	  
	  # TODO: skip most pages for file with many pages
	  if page_no > (reader.pages.length-3) then
		  print "\n###--- Page No.=#{page_no}" #" , #{page.text.inspect.strip[0..100]}"

		  dates = page.text.inspect.strip.scan(/\((\d\d\d\d)\)/)
		  if dates.size == 0 then
			# try other format
			dates = page.text.inspect.strip.scan(/(\d\d\d\d)/)
		  end
		  
		  print "###--- dates #{dates.size}\n"
		  
		  if dates.size > 0 then
			all_dates << dates
		  end
	  
	  end
	  
      #puts page.fonts
      #puts page.text
      #puts page.raw_content
	  
	  if page_no==(1 + n_skipped_pages_at_the_begining) then
	  
		page_raw_content=page.text.inspect.strip.gsub(/\\n/, " ").gsub(/\s+/," ")
		if !page_raw_content.include?("http://www.tandfonline.com/action/journalInformation") and
		   !page_raw_content.include?("https://www.researchgate.net/publication") and
		   !page_raw_content.include?("SFI WORKING PAPER") and	
		   !page_raw_content.include?("This article appeared in a journal published by Elsevier") then
	  
			possible_title = page.text.inspect.strip.gsub(/\\n/, " ").gsub(/\s+/," ")[0..200]
			print "possible title: #{possible_title} \n"
			
			# TODO: try to get an author name from the second line of the title
			lines = page.text.inspect.strip.split('\n')
			lines = lines.reject { |c| c.empty? }
			print "### ### lines: length=#{lines.length} \n"
			if lines.length > 1
				print "### ### lines: 0=#{lines[0]} \n"
				print "### ### lines: 1=#{lines[1]} \n"
				print "### ### lines: 2=#{lines[2]} \n"	
				print "### ### lines: 3=#{lines[3]} \n"	
				print "### ### lines: 4=#{lines[4]} \n"	

				
				paper_metadata.set_title_from_pdf_first_page possible_title, lines

				paper_metadata.set_author_from_pdf_first_page lines
			else
				print "### ### No text found, trying OCR ... \n"
				# TODO: OCR page
			end
		else
			n_skipped_pages_at_the_begining = n_skipped_pages_at_the_begining + 1
		end
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
		
		# TODO: revert to OCR pages, if possible
	end
	
	paper_metadata.clean_author
	paper_metadata.clean_title
	paper_metadata.dump
	
	return paper_metadata
end



PDF_TARGET_PATH="G:\\TEMP\\PDF\\Inbox"

def check_for_pdf_files pdf_path

	puts "Checking for pdf files ..."
	puts "-------------\n\n"

	if File.directory?(pdf_path)
		pdf_files= `dir #{pdf_path}\\*.pdf\ /b /s /a-d`
	else
		pdf_files= `dir #{pdf_path} /b`
	end
	
	caps = pdf_files.scan(/(.*)\n/)

		

	puts "Found files:\n #{caps} \n\n"

	
	caps.each do |i|
		STDERR.write "#{i[0]} \n"
	
		begin 
		status = Timeout::timeout(15) {	
			info = print_pdf_info i[0]	 
		
			if !info.nil? then
				info.move_and_rename PDF_TARGET_PATH
			end
		}
		rescue
			STDERR.write "!!! TIMED-OUT #{i[0]} \n"
		end
		
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


