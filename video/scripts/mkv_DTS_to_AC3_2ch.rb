#
#   mkv_DTS_to_AC3_2ch.rb
#   ================================
#   converts audio to be compatible with NMT100 (Popcorn hour)
#
#   Copyright (C) 2017 Pedro Mendes da Silva 
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


def mkv_DTS_to_AC3_2ch input_file_name,output_file_name
	date=  "2017"
	genre= "Popcorn"
	album= "Popcorn NMT100"
   
   metadata = "-metadata artist=\"Pedro\" -metadata genre=\"#{genre}\" -metadata date=\"#{date}\" -metadata album=\"#{album}\" "
   
   # convert audio
   system "\"#{FFMPEG_PATH}ffmpeg\" #{FFMPEG_HDACCEL} -i \"#{input_file_name}\" -c:v copy -acodec ac3 -ac 2 \"#{output_file_name}\" "

end

# TODO: automate dependencies and directories (currently hardcoded)
FFMPEG_PATH="D:\\Program Files\\ffmpeg-20161210\\bin\\"
FFMPEG_HDACCEL="-hwaccel dxva2 -threads 1"

SOURCE_PATH=ARGV[0]
TARGET_PATH="G:\\temp\\"

target_video_filename = "#{TARGET_PATH}\\#{SOURCE_PATH}.AC3.2ch.mkv"

print "mkdir \"#{TARGET_PATH}\""
system "mkdir \"#{TARGET_PATH}\""

PAUSE=false

puts "\nmkv_DTS_to_AC3_2ch - converts mkv audio to be compatible with NMT100 (Popcorn hour)"
puts "-------------\n\n"

if SOURCE_PATH.nil?
	puts "Usage: mkv_DTS_to_AC3_2ch.rb [source file]\n\n"
	exit -1
end

mkv_DTS_to_AC3_2ch SOURCE_PATH,target_video_filename