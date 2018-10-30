#
#   mp3_to_mp4.rb
#   =============
#
#   Creates an mp4 video with the given mp3 audio file and an image.
#   The video duration is set to the mp3 duration.
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


def get_mp3_duration file

	file_info = `\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{file}\" 2>&1`

	#puts "file info=#{file_info}"
	
	duration = file_info.scan(/..:..:..\.../)
	
	#puts "MP3 duration=#{duration}"
	
	return duration[0]
end

# TODO: automate dependencies and directories (currently hardcoded)
FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
EAC3TO_PATH="D:\\Program Files (x86)\\eac3to331\\"
TARGET_PATH=".\\"
#IMAGE_PATH="\"d:\\Mais imagens\\Cartazes\\DJ Estaline\\Caixode do lixo.jpg\""
#IMAGE_PATH="\"d:\\Mais imagens\\Cartazes\\DJ Estaline\\botastexas.jpg\""
#IMAGE_PATH=".\\Mito_Duplo_Radio_Full_HD_v2.jpg"
#IMAGE_PATH="\"G:\\Downloads\\Israel\\MArina.jpg\""

MP3_PATH = ARGV[0]

IMAGE_PATH="\"#{MP3_PATH}.png\""

puts "mp3_to_mp4.rb - Creates an mp4 video with the given mp3 audio file and an image"
puts "-------------"

puts "mp3=#{MP3_PATH}"

extra_options = "-framerate 1"
extra_options_igtv = "-framerate 30"

extra_options=extra_options_igtv

if MP3_PATH

	MP4_PATH = "#{MP3_PATH}.mp4"

	puts "mp4=#{MP4_PATH}"
	
	mp3_duration = get_mp3_duration MP3_PATH
	
	puts "MP3 duration=#{mp3_duration}"

	seconds_per_image=20
		
    puts "Converting...\n\n"	
	# -pix_fmt yuv420p 
	system "\"#{FFMPEG_PATH}ffmpeg.exe\" -loop 1 #{extra_options}  -i #{IMAGE_PATH} -i \"#{MP3_PATH}\" -t #{mp3_duration} -pix_fmt yuv420p \"#{MP4_PATH}\""
else

	puts "Invalid args"
end