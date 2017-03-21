#
#   images_to_ebook.rb
#   ==================
#   Converts a set of images to ebooks
#
#   Currently supported book formats:
#   - HTML + images
#
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

require_relative "../../framework/scripts/framework_utils.rb"



def html_ebook_start metadata
	string = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
	string = string + "<head>\n"
	string = string + "<title>#{metadata.title}</title>\n"
	string = string + "</head>\n"
	string = string + "<body>\n"
	
	return string
end

def html_ebook_end
	string = "</body>\n"
	string = string + "</html>\n"
	return string
end

def html_ebook_add_image image_name
	string = "<p><img class=\"video_frame\" alt=\"#{image_name}\" src=\"#{image_name}\"></img></p>\n"
	# string = string + "<p class=\"video_frame_caption\">#{image_name}</p>\n"
	
	# TODO: no caption
	
	return string
end

def html_ebook_add_link file_name, description

	puts "html_ebook_add_link: #{file_name} \n"

	string = "<p><a class=\"index\" href=\"#{file_name}\">#{description}</a></p>\n"
	
	return string
end

def html_ebook_add_item item_name

	item_mimetype = get_mime_type_from_extension item_name

	if ( (item_mimetype == "text/html") or (item_mimetype == "application/xhtml+xml") )
		html_ebook_add_link item_name, item_name
	else
		html_ebook_add_image item_name
	end
end

def epub_content_opf_start metadata

	# TODO: real metadata: title, author, ...

	string = "<?xml version='1.0' encoding='utf-8'?>\n"
	string = string + "<package xmlns=\"http://www.idpf.org/2007/opf\" unique-identifier=\"uuid_id\" version=\"2.0\">\n"
	string = string + "<metadata xmlns:calibre=\"http://calibre.kovidgoyal.net/2009/metadata\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:opf=\"http://www.idpf.org/2007/opf\">\n"
	string = string + "  <dc:title>#{metadata.title}</dc:title>\n"
	string = string + "  <dc:creator opf:role=\"aut\" opf:file-as=\"zerosociety\">#{metadata.author}</dc:creator>\n"
	string = string + "  <dc:identifier id=\"uuid_id\" opf:scheme=\"uuid\">f07bb25c-ab9d-4252-b23f-4943dd8259c4</dc:identifier>\n"
	string = string + "  <dc:date>0101-01-01T00:00:00+00:00</dc:date>\n"
	string = string + "  <dc:contributor opf:role=\"bkp\">zerosociety</dc:contributor>\n"
	string = string + "  <dc:subject>zerosociety</dc:subject>\n"
	string = string + "  <dc:language>english</dc:language>\n"
	string = string + "  <dc:identifier opf:scheme=\"calibre\">f07bb25c-ab9d-4252-b23f-4943dd8259c4</dc:identifier>\n"
	string = string + "  <meta name=\"calibre:timestamp\" content=\"2017-03-05T11:52:27.546000+00:00\"/>\n"
	string = string + "  <meta name=\"cover\" content=\"cover\"/>\n"
	string = string + "  <meta name=\"calibre:title_sort\" content=\"#{metadata.author}\"/>\n"
	string = string + "</metadata>\n"
	string = string + "<manifest>\n"
	
	return string
end

def epub_content_opf_add_manifest_link file_name, id, media_type

	#puts "epub_content_opf_add_manifest_link >> #{file_name} #{id} #{media_type}\n"

	string = "   <item href=\"#{file_name}\" id=\"#{id}\" media-type=\"#{media_type}\"/>\n"
	return string
end

def epub_content_opf_end_manifest_start_spine 
	
	string = "</manifest>\n<spine toc=\"ncx\">\n"
	
	# TODO: NCX
	
	return string
end

def epub_content_opf_add_spine_link id
	string = "   <itemref idref=\"#{id}\"/>\n"
	return string
end


def epub_content_opf_end first_page
	string = "</spine>\n"
	string = string + "<guide>\n"
	string = string + "   <reference href=\"titlepage.xhtml\" title=\"Cover\" type=\"cover\"/>"
	string = string + "   <reference type=\"toc\" title=\"Table of Contents\" href=\"toc.xhtml\"/>\n"
	string = string + "   <reference type=\"text\" title=\"Text\" href=\"#{first_page}\"/>\n"
	string = string + "</guide>\n"
	string = string + "</package>"
	return string
end

def images_to_html_ebook directory, target_filename, metadata

	image_files = `dir #{directory}\\*.jpg\ /od /b` 
	image_files = image_files + `dir #{directory}\\*.png\ /od /b` 

	system "mkdir #{directory}\\ebook"

	caps = image_files.scan(/(.*)?\.(.*)?/)

	puts "Found files:\n #{caps} \n\n"

	image_no = 1

	html_string = html_ebook_start metadata
	
	caps.each do |i|
	
	   image_name = caps[image_no-1][0] + "." + caps[image_no-1][1] 
	   #puts "Value of local variable is #{image_no} .. #{image_name}"
	   
	   html_string = html_string + html_ebook_add_image(image_name)
	   
	   image_no = image_no + 1
	end

	html_string = html_string + html_ebook_end
	
	#puts "book html:\n"
	#puts "-------------\n\n"
	#puts "#{html_string}\n"
	
	File.open(target_filename, 'w') { 
			|file| file.write(html_string)
	}
	
	return html_string
end


def images_to_multiple_html_files_ebook directory, target_directory, metadata, include_html_files

	if (metadata.nil?)
		metadata = OpenStruct.new
		metadata.title = "Title converted by Zerosociety"
		metadata.author = "Unknown"
	end

	image_files = `dir #{directory}\\*.jpg\ /od /b` 
	image_files = image_files + `dir #{directory}\\*.png\ /od /b` 

	if (include_html_files)
		image_files = image_files + `dir #{directory}\\*.xhtml\ /od /b` 
		image_files = image_files + `dir #{directory}\\*.html\ /od /b` 
		image_files = image_files + `dir #{directory}\\*.htm\ /od /b` 
	end
	
	create_dir target_directory
	
	#system "mkdir #{directory}\\ebook"

	caps = image_files.scan(/(.*)?\.(.*)?/)

	puts "Found files:\n #{caps} \n\n"

	image_no = 1
	
	first_page_filename = ""

	index_file_html_string = html_ebook_start metadata
	
	content_opf_file_string = epub_content_opf_start(metadata)
	content_opf_spine_string = ""
	
	caps.each do |i|

	   html_string = html_ebook_start(metadata)
	
	   image_name = caps[image_no-1][0] + "." + caps[image_no-1][1] 
	   #puts "Value of local variable is #{image_no} .. #{image_name}"
   
	    html_string = html_string + html_ebook_add_item(image_name)
	   
	    html_string = html_string + html_ebook_end
	   
	    copy_files_to_target_dir image_name, target_directory
		
		
		# Indexes

		item_mimetype = get_mime_type_from_extension image_name
		
		# TODO: option to use numbers instead of the file names as index entries
		if !( (item_mimetype == "text/html") or (item_mimetype == "application/xhtml+xml") )
			# Images
			index_file_html_string = index_file_html_string + html_ebook_add_link("#{image_name}.xhtml", image_name)
			content_opf_file_string = content_opf_file_string + epub_content_opf_add_manifest_link("#{image_name}.xhtml", "id#{image_no}", "application/xhtml+xml")
			content_opf_spine_string = content_opf_spine_string + epub_content_opf_add_spine_link("id#{image_no}")
		else
			# XHTML
			index_file_html_string = index_file_html_string + html_ebook_add_item(image_name)
			content_opf_spine_string = content_opf_spine_string + epub_content_opf_add_spine_link("idimg#{image_no}")
		end
		
		
		content_opf_file_string = content_opf_file_string + epub_content_opf_add_manifest_link(image_name, "idimg#{image_no}", get_mime_type_from_extension(image_name) )
	   

	   	
		# write an xhtml file for each image, skip for other item types
		if !( (item_mimetype == "text/html") or (item_mimetype == "application/xhtml+xml") )

			if image_no == 1
				first_page_filename = "#{image_name}.xhtml"
				#copy_and_rename_file_to_target_dir "#{image_name}", "cover.jpeg", target_directory
				image_convert "#{image_name}", "#{target_directory}\\cover.jpeg"
			end
		
			target_filename = "#{target_directory}\\#{image_name}.xhtml"
			
	
			#puts "page html:\n"
			#puts "-------------\n\n"
			#puts "#{html_string}\n"
	
			File.open(target_filename, 'w') { 
				|file| file.write(html_string)
			}
		end
		
		image_no = image_no + 1
	end

	content_opf_file_string = content_opf_file_string + epub_content_opf_add_manifest_link("titlepage.xhtml", "titlepage", "application/xhtml+xml")
	content_opf_file_string = content_opf_file_string + epub_content_opf_add_manifest_link("toc.xhtml", "idtoc", "application/xhtml+xml")
	content_opf_file_string = content_opf_file_string + epub_content_opf_add_manifest_link("toc.ncx", "ncx", "application/x-dtbncx+xml")
	content_opf_file_string = content_opf_file_string + epub_content_opf_add_manifest_link("cover.jpeg", "cover", "image/jpeg")

	content_opf_file_string = content_opf_file_string + epub_content_opf_end_manifest_start_spine 
	content_opf_file_string = content_opf_file_string + epub_content_opf_add_spine_link("titlepage")
	content_opf_file_string = content_opf_file_string + epub_content_opf_add_spine_link("idtoc") + content_opf_spine_string
	
	content_opf_file_string = content_opf_file_string + epub_content_opf_end(first_page_filename)
	
	index_filename = "#{target_directory}\\toc.xhtml"
	content_opf_filename = "#{target_directory}\\content.opf"
	
	index_file_html_string = index_file_html_string + html_ebook_end
	
	dump_file_from_string index_filename, index_file_html_string
	
	dump_file_from_string content_opf_filename, content_opf_file_string
	
end

# https://manual.calibre-ebook.com/generated/en/ebook-convert.html#pdf-output-options
# "soffice --headless --convert-to pdf mySlides.odp"

# \ebook-convert.exe" zeroconverted-Negoc.epub zeroconverted-Negoc.docx --docx-custom-page-size 1600x1000
# ebookconv2.cmd zeroconverted-Negoc.epub zeroconverted-Negoc.pdf --custom-size 11x8
# (inches)

CALIBRE_PATH="C:\\Program Files\\Calibre2\\"
def book_convert_EPUB_to_MOBI source, target

	puts "=== Creating .MOBI file (#{target}) ..."

	system "start \"MOBI\" /WAIT \"#{CALIBRE_PATH}ebook-convert\" \"#{source}\" \"#{target}\""
	
end

def book_convert_EPUB_to_PDF source, target

	puts "=== Creating .PDF file (#{target}) ..."

	# TODO: adjust target size based on the image sizes/aspect ration/orientation
	
	system "start \"PDF\" /WAIT \"#{CALIBRE_PATH}ebook-convert\" \"#{source}\" \"#{target}\" --custom-size 11x8"
	
end


def images_to_EPUB_ebook source_directory, target_directory, metadata
	images_to_multiple_html_files_ebook source_directory, target_directory, metadata, true
	resources_init __FILE__
	unzip_archive "#{resources_get_subdir("epub")}\\Template.epub.zip", "ebook"
	zip_dir_to_archive "ebook", "zeroconverted-#{metadata.title}.epub"
	epub_check_file "zeroconverted-#{metadata.title}.epub"
	
	book_convert_EPUB_to_MOBI "zeroconverted-#{metadata.title}.epub", "zeroconverted-#{metadata.title}.mobi"
	book_convert_EPUB_to_PDF  "zeroconverted-#{metadata.title}.epub", "zeroconverted-#{metadata.title}.pdf"
end



# TODO: automate dependencies and directories (currently hardcoded)

EPUBCHECK_PATH="d:\\Downloads\\epubcheck-3.0.1\\epubcheck-3.0.1\\"

# checks for errors in the epub file
def epub_check_file epub_file
	result = system "java -jar #{EPUBCHECK_PATH}\\epubcheck-3.0.1.jar \"#{epub_file}\" 2> \"#{epub_file}.errors.log\""
	
	return result
end


puts "images_to_ebook.rb - Converts a set of images to ebooks"
puts "-------------\n\n"

# TODO: optionally get metadata from the command line

metadata = OpenStruct.new

if ARGV[0].nil?
	metadata.title = "Unknown Title"
else
	metadata.title = ARGV[0]
end
metadata.author = "Desconhecido"

#images_to_html_ebook ".", "book_index.html", metadata

# TODO: move some of the EPUB methods to a library

images_to_EPUB_ebook ".", "ebook", metadata

# TODO: option to preview the generated ebooks
