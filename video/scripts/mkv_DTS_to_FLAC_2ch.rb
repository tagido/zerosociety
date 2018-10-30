#
#   mkv_DTS_to_flac_2ch.rb
#   ================================
#   converts audio from MKV to 2 channels flac
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



def mkv_DTS_to_flac_2ch input_file_name,output_file_name,skip_to
	#date=  "2017"
	#genre= "Popcorn"
	#album= "Popcorn NMT100"
   
   #metadata = "-metadata artist=\"Pedro\" -metadata genre=\"#{genre}\" -metadata date=\"#{date}\" -metadata album=\"#{album}\" "
   forcechannel=""
   forcechannel="-map 0:1"
   
   # convert audio
   call_ffmpeg_raw "-i \"#{input_file_name}\" #{forcechannel} -ss #{skip_to} -acodec flac -ac 2 \"#{output_file_name}\" ", false

end

SOURCE_PATH=ARGV[0]
TARGET_PATH="G:\\temp\\"

target_video_filename = "#{TARGET_PATH}\\#{SOURCE_PATH}.2ch.flac"

print "mkdir \"#{TARGET_PATH}\""
system "mkdir \"#{TARGET_PATH}\""

PAUSE=false

puts "\nmkv_DTS_to_FLAC_2ch - converts mkv audio to stereo FLAC"
puts "-------------\n\n"

if SOURCE_PATH.nil?
	puts "Usage: mkv_DTS_to_flac_2ch.rb [source file]\n\n"
	exit -1
end

if ARGV[1].nil? then
	skip_to = "0:09"
	skip_to = "0:11"
else
	skip_to=ARGV[1]
end

source_filename = "#{SOURCE_PATH}\\*.mkv"

system "dir \"#{source_filename}\" /b"
SOURCE_FILES= `dir \"#{source_filename}\" /b`

puts "#{SOURCE_FILES}\n"

caps = SOURCE_FILES.scan(/(.*)\n/)

puts "Found files:\n #{caps} \n\n"

#mkv_DTS_to_flac_2ch SOURCE_PATH,target_video_filename,skip_to


track_no = 1

system "mkdir flac"

# -metadata track=\"#{track_no}\"

caps.each do |i|
   puts "Value of local variable is  #{i}\n"

   output_filename = "flac\\#{i[0]}.2ch.flac"
 
   #system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{i[0]}\"   \"#{output_filename}\" 2>  \"mp3\\#{i[0]}.stderr.log\""
   
   mkv_DTS_to_flac_2ch i[0],output_filename,skip_to


   
   track_no = track_no + 1

   #add_jpg_cover_art_to_mp3 output_filename, "cover.jpg"
end


