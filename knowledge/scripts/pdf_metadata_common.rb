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
require 'bibtex'
require 'nokogiri'
require 'csv'

#
# inspired by https://darrennewton.com/2010/09/05/convert-csv-to-text-with-ruby/
#
def csv_to_array(file_location)
 csv = CSV::parse(File.open(file_location, 'r') {|f| f.read }, { :col_sep => "\t" })
 fields = csv.shift
 csv.collect { |record| Hash[*fields.zip(record).flatten ] } 
end

RANKINGS = csv_to_array('D:\Mais documentos\Projectos\Ruby scripts\zerosociety\knowledge\scripts\resources\CORE_2018_ConferenceRanking.csv')
#print RANKINGS
def dump_rankings
  RANKINGS.each do |row|
   print "#{row["shortname"]},"
  end
end

def get_ranking_by_shortname shortname
  begin
  if shortname.nil?
	return nil
  end

  RANKINGS.each do |row|
     print "#{row["shortname"]},"

   if !row["shortname"].nil? and (row["shortname"].strip == shortname) then
	return row
   end
  end
  
  rescue
  end
  
  return nil
end

dump_rankings

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
    @doi=""
	@proceedings=""
	@proceedings_start_page = ""
	@proceedings_end_page = ""
	@proceedings_conference_acronym = ""
	@proceedings_conference_short_year = ""	

	
	@bibref = BibTeX::Entry.new
	@bibref.type = :article


  end
 
  def set_year_from_all_text year
	if (@year==-1)
		@year=year
	end
  end
  
  def set_year_from_proceedings year
	@year=year
  end
  
  def clean_metadata_string metatata_str
	print "###  clean_metadata_string (encoding=#{metatata_str.encoding}) #{metatata_str} \n"
	#metatata_str.gsub!(/\\u2019/,'\'')
	metatata_str=metatata_str.strip.encode("US-ASCII",:undef => :replace, :invalid => :replace, :replace => "")
	print "###     cleaned= (encoding=#{metatata_str.encoding}) #{metatata_str} \n"
	
	return metatata_str
  end
  
  def set_title_from_pdf_metadata title
	if (!title.nil?) and 
	   !(title.start_with?("Microsoft Word - ")) and  
	   !(title.start_with?("PII: ")) and 
	   !(title.start_with?("Acrobat Distiller")) and   
	   !(title.start_with?("Proceedings Template")) and
	   !title.start_with?("pnas") then
		@title=clean_metadata_string(title)
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
		   lines[@n_skipped_first_page_lines].include? "DOI " or
		   lines[@n_skipped_first_page_lines].include? "New Political Economy" or
		   lines[@n_skipped_first_page_lines].include? "personal copy" or
		   lines[@n_skipped_first_page_lines].include? "Journal" or	  
		   lines[@n_skipped_first_page_lines].include? "JOURNAL" or	 
		   lines[@n_skipped_first_page_lines].include? "ARTICLE" or	   		     		   
		   lines[@n_skipped_first_page_lines].include? "www.elsevier.com" or
		   lines[@n_skipped_first_page_lines].include? "SciVerse ScienceDirect" or	   
		   lines[@n_skipped_first_page_lines].include? "week ending" or 
		   lines[@n_skipped_first_page_lines].include? "\"REVIEW" or
		   lines[@n_skipped_first_page_lines].include? "Proceedings" or
		   lines[@n_skipped_first_page_lines].include? "Bulletin" or
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
		#@title.gsub!(/\u00A0/, ' ')
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
	
	# remove "strange chars"
	@author.gsub!(/\\u00F6/,'oe')
   end
 
   def set_author_from_pdf_metadata author
	if !author.nil? and author.length > 0 
		@author=clean_metadata_string(author)
	end
   end
 
  def set_author_from_pdf_first_page lines
  
	if (@author == "UNK") and (!lines.nil?) then
	
		print "author @n_skipped_first_page_lines=#{@n_skipped_first_page_lines} ...\n"
	
		@n_skipped_first_page_lines = @n_skipped_first_page_lines + 1
	
	    new_author = lines[@n_skipped_first_page_lines].strip.gsub(/ /,'').gsub(/\\u\d\d\d\d/,'')
		print "|#{new_author}| len=#{new_author.length}\n"
		
		while (new_author.include? "Article" or 
				new_author.include? "author" or 
				new_author.include? "DOI:" or 
				new_author.include? "CITATIONS" or new_author.length < 9)
			print "author @n_skipped_first_page_lines=#{@n_skipped_first_page_lines} ...\n"

			@n_skipped_first_page_lines = @n_skipped_first_page_lines + 1
			new_author = lines[@n_skipped_first_page_lines].strip.gsub(/ /,'')
		end
		
		# restore spaces
		new_author = lines[@n_skipped_first_page_lines].gsub(/[\s\b\v]+/, " ").strip
		
		@author=new_author
	end
  
	# truncate very long names
  
  end
  
  #
  # inspired by https://stackoverflow.com/questions/27910/finding-a-doi-in-a-document-or-page
  #
  def set_doi_from_pdf_first_page raw_text
  	print "### set_doi_from_pdf_first_page\n"
	
 
	dois = raw_text.scan(/\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])[[:graph:]])+)\b/)
	
	print "dois=#{dois}\n"
	if dois.length > 0
	    @doi=dois[0][0]
		print "### ### found good doi=#{@doi}\n"
	end

  end
  
  def set_proceedings_from_pdf_first_page raw_text
  	print "### set_proceedings_from_pdf_first_page\n"
	
	proceedings = raw_text.scan(/Proceedings of the (.*?)(\n|\.)/)

	print "proceedings=#{proceedings}\n"

	if proceedings.length > 0
	    @proceedings=proceedings[0][0]
		@proceedings.gsub!(/\\u2018/,'\'')
		@proceedings.gsub!(/\\u2019/,'\'')
		@proceedings.gsub!(/\\u2013/,'-')
		print "### ### found good proceedings=#{@proceedings}\n"
		
		# Subitems parsing
		
		dates =@proceedings.scan(/(\d\d\d\d)/)
		if dates.length > 0
			set_year_from_proceedings dates[0][0]
		end
		
		pages =@proceedings.scan(/pages (\d*)-(\d*)/)
		if pages.length > 0
			print "### ### found good pages=#{pages}\n"
			set_pages_from_proceedings pages[0][0],pages[0][1]
		end
		
		series=@proceedings.scan(/([A-Z]{3,})\s?'(\d\d)/)    # e.g. {AAMAS '16}
		if series.length > 0
			print "### ### found good series=#{series}\n"
			set_series_from_proceedings series[0][0],series[0][1]
		end
	end
	
  end

  def set_pages_from_proceedings start_page, end_page
	@proceedings_start_page = start_page
	@proceedings_end_page =   end_page	
  end
  
  def set_series_from_proceedings conference_acronym, conference_short_year
	@proceedings_conference_acronym = conference_acronym
	@proceedings_conference_short_year =   conference_short_year	
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
  
  def update_bibref
	@bibref.title = @title
	@bibref.year = @year
	@bibref.author = @author
	@bibref.doi = @doi
	@bibref.file = ":#{get_new_filename}:PDF"
	@bibref.comment = "Generated by zero. Original file: #{@filename}"
	
	@bibref.journal = "TODO"
	@bibref.volume = "TODO"
	@bibref.number = "TODO"

	
	
	if !(@proceedings_start_page=="")
		@bibref.pages = "#{@proceedings_start_page}-#{@proceedings_end_page}"
		@bibref.numpages  = @proceedings_end_page.to_i - @proceedings_start_page.to_i + 1
	end
		

	@bibref.keywords = "TODO"
	@bibref.publisher = "TODO"
	
	# Proceedings
	#
	# Revistas (@article) vs Confs. (@InProceedings)
	#  PNAS, RoyalSociety, Nature vs ... 
	#
	# Verificar automaticamente o "nivel" da conf
	
	#abstract
	#url
	#isbn
	#  booktitle = {Proceedings of the 2016 International Conference on Autonomous Agents \&\#38; Multiagent Systems},
    if 	!(@proceedings=="")
		@bibref.type = :inproceedings
		@bibref.booktitle = @proceedings
	end
	

	
	 if !(@proceedings_conference_acronym=="")
	 	@bibref.series = "#{@proceedings_conference_acronym}'#{@proceedings_conference_short_year}"
		@bibref.comment = "#{@bibref.comment}. Conference: #{@proceedings_conference_acronym}."
	 
		ranking=get_ranking_by_shortname @proceedings_conference_acronym
		if !ranking.nil? then
			print "found ranking=#{ranking}\n"
			ranking_str = ranking["rank"]
			fullname_str = ranking["fullname"]
		else
			ranking_str = "Not Available"
			fullname_str = "Not Available"
		end
		@bibref.comment = "#{@bibref.comment}. CORE Rank: #{ranking_str}. A.K.A.: #{fullname_str}"
		

	 end
	
	#@InProceedings{Santos2016,
#  author    = {Santos, Fernando P. and Santos, Francisco C. and Melo, Francisco and Paiva, Ana and Pacheco, Jorge M.},
#  title     = {Learning to Be Fair in Multiplayer Ultimatum Games: (Extended Abstract)},

#  booktitle = {Proceedings of the 2016 International Conference on Autonomous Agents \&\#38; Multiagent Systems},
#  year      = {2016},
#  series    = {AAMAS '16},

#  pages     = {1381--1382},
#  address   = {Richland, SC},
#  publisher = {International Foundation for Autonomous Agents and Multiagent Systems},
#  acmid     = {2937170},
#  isbn      = {978-1-4503-4239-1},
#  keywords  = {fairness, groups, learning, multiagent systems, ultimatum game},
#  location  = {Singapore, Singapore},
#  numpages  = {2},
#  url       = {http://dl.acm.org/citation.cfm?id=2936924.2937170},
#}

	#crossref - The key of the cross-referenced entry
	
	# aspect-ratio / orientation (slides ?)
  end
  
  #
  # https://en.wikipedia.org/wiki/BibTeX
  #
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
	print "DOI:#{@doi}\n"
	update_bibref 
	print "bibref:#{@bibref}\n"
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
		page_raw_content_with_newlines = page.text.inspect.strip
		
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
		
		paper_metadata.set_doi_from_pdf_first_page  page_raw_content
		paper_metadata.set_proceedings_from_pdf_first_page  page_raw_content
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
	
	paper_metadata.set_year_from_all_text possible_paper_year
	
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
		rescue => exception
			STDERR.write "!!! TIMED-OUT #{i[0]} \n#{exception.backtrace}"
			print "!!! TIMED-OUT #{i[0]} \n#{exception.backtrace}\n"
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


