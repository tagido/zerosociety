#
#   mp4_deinterlace_and_stabilize.rb
#   ================================
#   Deinterlaces and stabilizes a set of .mp4 files
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

require 'ostruct'

origin = OpenStruct.new
origin.x = 0
origin.y = 0

# Wait for the spacebar key to be pressed
def wait_for_spacebar
   print "Press space to continue ...\n"
   sleep 1 while $stdin.getc != " "
end



def conv_hhmmss_to_seconds time_string

 seconds = "#{time_string}".split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b}

 return seconds
 
end


def convert_chapter input_file_name,file_index
	date=  "2016"
	genre= "Viagens"
	album= "Acores"
   
   metadata = "-metadata title=\"Track #{file_index}\" -metadata artist=\"Pedro\" -metadata genre=\"#{genre}\" -metadata date=\"#{date}\" -metadata album=\"#{album}\" -metadata track=\"#{file_index}\""
   

   #Deinterlace to 50 fps -aspect 16:9
   system "\"#{FFMPEG_PATH}ffmpeg\" #{FFMPEG_HDACCEL} -i \"#{input_file_name}\" -vf \"yadif=1:-1:0\" -c:v mpeg2video -b:v 6000k -target pal-dvd #{metadata}  \"#{input_file_name}.yadif.mpg\""
  
   #Get motion vectors
   system "\"#{FFMPEG_PATH}ffmpeg\" #{FFMPEG_HDACCEL} -i \"#{input_file_name}.yadif.mpg\" -vf \"vidstabdetect=stepsize=6:shakiness=8:accuracy=9:result=transform_vectors2.trf\" -f null -"

   #Stabilize using the motion vectors     
   system "\"#{FFMPEG_PATH}ffmpeg\" #{FFMPEG_HDACCEL} -i \"#{input_file_name}.yadif.mpg\" -vf \"vidstabtransform=input=transform_vectors2.trf:zoom=1:smoothing=30,unsharp=5:5:0.8:3:3:0.4, fps=25\" -c:v mpeg2video -b:v 8000k -target pal-dvd -acodec copy #{metadata} \"#{input_file_name}.yadif.deshaker.mpg\""
end


def check_mp4_files directory

	puts "Checking for unibanco files ..."
	puts "-------------\n\n"

	unibanco_files= `dir #{directory}\\*.mp4 /b /s`

	caps = unibanco_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"
	
	index = 1
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
	   
	   input_file_name = "#{i[0]}"
	   
	   convert_chapter input_file_name, index
 
	  
	  index = index + 1 
	end

end

# TODO: automate dependencies and directories (currently hardcoded)
FFMPEG_PATH="D:\\Program Files\\ffmpeg-20161210\\bin\\"
FFMPEG_HDACCEL="-hwaccel dxva2 -threads 1"
HANDBRAKECLI_PATH="D:\\Program Files\\Handbrake\\"
DD_PATH="D:\\Downloads\\dd-0.6beta3\\"
DVD_MEDIA_INFO_PATH="D:\\Downloads\\dd-0.6beta3\\"

time = Time.now.getutc
time2 = time.to_s.delete ': '

#time2 = "tmp"

TARGET_PATH="G:\\temp\\dvd_extract_and_stabilize\\dvd.#{time2}"

tmp_vectors_filename = "#{TARGET_PATH}\\transform_vectors.trf"
target_video_filename = "#{TARGET_PATH}\\dvd_full.mp4"

print "mkdir \"#{TARGET_PATH}\""

system "mkdir \"#{TARGET_PATH}\""


PAUSE=false

puts "\nmp4_deinterlace_and_stabilize.rb - Deinterlace and stabilize mp4 video"
puts "-------------\n\n"

check_mp4_files "."