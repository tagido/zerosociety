#
#   images_to_pptx.rb
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

require 'powerpoint'
require_relative "../../framework/scripts/framework_utils.rb"

# https://manual.calibre-ebook.com/generated/en/ebook-convert.html#pdf-output-options
# "soffice --headless --convert-to pdf mySlides.odp"

# \ebook-convert.exe" zeroconverted-Negoc.epub zeroconverted-Negoc.docx --docx-custom-page-size 1600x1000
# ebookconv2.cmd zeroconverted-Negoc.epub zeroconverted-Negoc.pdf --custom-size 11x8
# (inches)

CALIBRE_PATH="C:\\Program Files\\Calibre2\\"

def book_convert_PPTX_to_PDF source, target

	puts "=== Creating .PDF file (#{target}) ..."

	# TODO: adjust target size based on the image sizes/aspect ration/orientation
	
	system "start \"PDF\" /WAIT \"#{CALIBRE_PATH}ebook-convert\" \"#{source}\" \"#{target}\" --custom-size 11x8"
	
end

def check_pptx_file pptx_filename
		puts "=== Checking .PPTX file (#{pptx_filename}) ..."
		system "cmd /C dir \"#{pptx_filename}\""
		puts "=== Opening .PPTX file (#{pptx_filename}) ..."
		system "start \"PDF\" /WAIT \"#{pptx_filename}\""
end

#	@deck.add_pictorial_slide title, image_path, coords
#
# TODO: adjust target size based on the image sizes/aspect ration/orientation
# TODO: reduzir resolucao se for muito grande
def convert_image_to_pptx_slide deck, image_path, metadata

	aux_x= 12700 * (1)
	aux_cx = 12700 * 712
	aux_y= 12700 * 1
	aux_cy= 12700 * 512

	print "... Adding slide with #{image_path}\n"
	
	coords = {x: aux_x, y: aux_y, cx: aux_cx, cy: aux_cy}
	deck.add_pictorial_slide image_path, image_path, coords
end		


def images_to_pptx_ebook source_directory, target_directory, metadata
		
	# gem install powerpoint
	# https://github.com/pythonicrubyist/powerpoint

	@deck = Powerpoint::Presentation.new

	# Creating an introduction slide:
	subtitle = 'generated with ZeroSociety'
	title = metadata.title
	@deck.add_intro title, subtitle

	# Creating a text-only slide:
	# Title must be a string.
	# Content must be an array of strings that will be displayed as bullet items.
	title = metadata.title
	content = ['Its cool!', 'Its light.']
	#@deck.add_textual_slide title, content

	# Creating an image Slide:
	# It will contain a title as string.
	# and an embeded image
	title = 'Everyone loves Macs:'
	image_path = 'img.png'
	#@deck.add_pictorial_slide title, image_path

	# Specifying coordinates and image size for an embeded image.
	# x and y values define the position of the image on the slide.
	# cx and cy define the width and height of the image.
	# x, y, cx, cy are in points. Each pixel is 12700 points.
	# coordinates parameter is optional.

	#coords = {x: aux_x, y: aux_y, cx: aux_cx, cy: aux_cy}
	#@deck.add_pictorial_slide title, image_path, coords
	
	image_files = `dir #{source_directory}\\*.jpg\ /od /b` 
	image_files = image_files + `dir #{source_directory}\\*.png\ /od /b` 

	system "mkdir #{source_directory}\\#{target_directory}"

	caps = image_files.scan(/(.*)?\.(.*)?/)

	puts "Found files:\n #{caps} \n\n"

	caps.each do |i|
	
		#coords = {x: aux_x, y: aux_y, cx: aux_cx, cy: aux_cy}
		#@deck.add_pictorial_slide i[0], i[0]+"."+i[1], coords
		
		convert_image_to_pptx_slide @deck,  i[0]+"."+i[1], metadata
		
	end
	
	title = 'Generated with Zero Society tools'
	content = ['github:', 'tagido/zerosociety']
	@deck.add_textual_slide title, content
	
	# Saving the pptx file to the current directory.
	pptx_filename = target_directory + "\\converted.pptx"
	puts "=== Saving .PPTX file (#{pptx_filename}) ...\n"
	@deck.save(pptx_filename)
	
	#pdf_filename = target_directory + "\\converted.pdf"
	#book_convert_PPTX_to_PDF pptx_filename, pdf_filename
	
	check_pptx_file pptx_filename
end



# TODO: automate dependencies and directories (currently hardcoded)



puts "images_to_pptx.rb - Converts a set of images to ebooks"
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

# TODO: move some of the pptx methods to a library

images_to_pptx_ebook ".", "pptx", metadata

# TODO: add option to group images in the same page (by prefix)
# TODO: remove tmp files
# TODO: option to preview the generated ebooks
# TODO: conversion to PPTX and MP4