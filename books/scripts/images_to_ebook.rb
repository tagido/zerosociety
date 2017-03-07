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

# TODO: automate dependencies and directories (currently hardcoded)
FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
EAC3TO_PATH="D:\\Program Files (x86)\\eac3to331\\"
BLURAY_PATH="G:."
TARGET_PATH="G:.\\"


def html_ebook_start
	string = "<html>\n"
	string = string + "<body>\n"
	string = string + "<style>\n"
	string = string + ".video_frame_caption { font-size: 1.5em;}\n"
	string = string + "</style>\n"
	
	# TODO: encoding, metadata, style, multiple pages
	# TODO: image metadata
	
	return string
end

def html_ebook_end
	string = "</body>\n"
	string = string + "</html>\n"
	return string
end

def html_ebook_add_image image_name
	string = "<img class=\"video_frame\" src=\"#{image_name}\"></img>\n"
	string = string + "<p class=\"video_frame_caption\">#{image_name}</p>\n"
	return string
end



def images_to_html_ebook directory, target_filename

	image_files = `dir #{directory}\\*.jpg\ /b` 
	image_files = image_files + `dir #{directory}\\*.png\ /b` 

	system "mkdir #{directory}\\ebook"

	#system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{SOURCE_DRIVE}\\MPEGAV\\AVSEQ01.DAT\"  -codec:a libmp3lame -qscale:a 2 \"#{TARGET_FILENAME}\".vcd.mp3"

	caps = image_files.scan(/(.*)?\.(.*)?/)

	puts "Found files:\n #{caps} \n\n"

	image_no = 1

	html_string = html_ebook_start 
	
	caps.each do |i|
	
	   image_name = caps[image_no-1][0] + "." + caps[image_no-1][1] 
	   puts "Value of local variable is #{image_no} .. #{image_name}"

	   #system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{SOURCE_DRIVE}\\MPEGAV\\#{i}.DAT\" -metadata track=\"#{track_no}\"  -codec:a libmp3lame -qscale:a 2 \"#{TARGET_FILENAME}\".vcd.#{track_no}.mp3"
	   
	   html_string = html_string + html_ebook_add_image(image_name)
	   
	   image_no = image_no + 1
	end

	html_string = html_string + html_ebook_end
	
	puts "book html:\n"
	puts "-------------\n\n"
	puts "#{html_string}\n"
	
	File.open(target_filename, 'w') { 
			|file| file.write(html_string)
	}
	
	return html_string
end

puts "images_to_ebook.rb - Converts a set of images to ebooks"
puts "-------------\n\n"

images_to_html_ebook ".", "index.html"

#TODO: convert HTML to EPUB