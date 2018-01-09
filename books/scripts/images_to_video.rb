#
#   images_to_video.rb
#   ==================
#   Converts a set of images to a video
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

require 'powerpoint'
require_relative "../../framework/scripts/framework_utils.rb"

# https://manual.calibre-ebook.com/generated/en/ebook-convert.html#pdf-output-options
# "soffice --headless --convert-to pdf mySlides.odp"

# \ebook-convert.exe" zeroconverted-Negoc.epub zeroconverted-Negoc.docx --docx-custom-page-size 1600x1000
# ebookconv2.cmd zeroconverted-Negoc.epub zeroconverted-Negoc.pdf --custom-size 11x8
# (inches)

CALIBRE_PATH="C:\\Program Files\\Calibre2\\"
FFMPEG_PATH="D:\\Program Files\\ffmpeg-20180102\\bin\\"



def check_video_file video_filename
		puts "=== Checking .MP4 file (#{video_filename}) ..."
		system "cmd /C dir \"#{video_filename}\""
		puts "=== Playing .MP4 file (#{video_filename}) ..."
		system "cmd /C \"#{video_filename}\""
		
end



def images_to_video source_directory, target_directory, metadata
	
	video_filename="#{target_directory}\\#{metadata.title}-images_to_video.mp4"
	
	audio_filename="G:\\Downloads\\Telediscos\\Pianadas (DJ Estaline)\\Pianadas\\HDAudio\\DJ Estaline - Sonata ao luar .wav"

	copy_and_rename_file_to_target_dir audio_filename, "Sonata.wav", "."
	
	image_name_pattern="page%d.png"
	
	cmd="\"#{FFMPEG_PATH}ffmpeg.exe\" -framerate 1/20 -i #{image_name_pattern}  -filter_complex amovie=Sonata.wav:loop=0,asetpts=N/SR/TB,aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo -shortest -vf scale=1920:1080 -c:v libx264  -r 25 -pix_fmt yuv420p \"#{video_filename}\""

	#cmd="\"#{FFMPEG_PATH}ffmpeg.exe\" -filter_complex amovie=Sonata.wav:loop=3,asetpts=N/SR/TB,aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo  -vf scale=1920:1080 -c:v libx264  -r 25 -pix_fmt yuv420p #{video_filename}.mp3"

	puts "=== Creating .MP4 file (#{video_filename}) ..."
	puts "#{cmd} \n"
	system "#{cmd}"
	
	check_video_file video_filename
end

# TODO: automate dependencies and directories (currently hardcoded)

puts "images_to_video.rb - Converts a set of images to a video"
puts "-------------\n\n"

# TODO: optionally get metadata from the command line

metadata = OpenStruct.new

if ARGV[0].nil?
	metadata.title = "Unknown Title"
else
	metadata.title = ARGV[0]
end
metadata.author = "Unknown Author"

target_dir="mp4"

create_dir target_dir

images_to_video ".", target_dir, metadata

