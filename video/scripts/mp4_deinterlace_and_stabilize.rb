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

require_relative "../../framework/scripts/framework_utils.rb"

require 'ostruct'


origin = OpenStruct.new
origin.x = 0
origin.y = 0




def convert_chapter input_file_name,file_index, target_path
	date=  "2016"
	genre= "Viagens"
	album= "Acores"
	
   print "### Stabilize FILE #{file_index} #{input_file_name} #{target_path} ...\n"
	
	target_yaddif_filename="#{target_path}\\#{File.basename(input_file_name)}.yadif.mpg"
	target_stabilized_filename="#{target_path}\\#{File.basename(input_file_name)}.yadif.deshaker.mpg"
   
   #tmp
   #target_yaddif_filename=input_file_name
   
   target_tv_system="pal-dvd"
   #target_tv_system="ntsc-dvd"
   
   target_aspect_ratio="16:9"
   #target_aspect_ratio="4:3"
   
   metadata = "-metadata title=\"Track #{file_index}\" -metadata artist=\"Pedro\" -metadata genre=\"#{genre}\" -metadata date=\"#{date}\" -metadata album=\"#{album}\" -metadata track=\"#{file_index}\""
   
   filter="-vf \"yadif=1:-1:0\""
   #-vf mp=eq2=gamma:contrast:brightness:saturation:rg:gg:bg:weight
   # contrast : brightness : saturation : gamma : gamma r : gamma g : gamma b : weight
   #  https://wjwoodrow.wordpress.com/2015/07/12/more-ffmpeg-hell/
   #filter="-vf \"bwdif\" -vf eq=1.2:0:1.6:1:1:1:1:1"

   #Deinterlace to 50 fps -aspect 16:9
   system "\"#{FFMPEG_PATH}ffmpeg\" #{FFMPEG_HDACCEL} -i \"#{input_file_name}\" -aspect #{target_aspect_ratio} #{filter} -c:v mpeg2video -b:v 6000k -target #{target_tv_system} #{metadata}  \"#{target_yaddif_filename}\""

#return
   
   #Get motion vectors
   system "\"#{FFMPEG_PATH}ffmpeg\" #{FFMPEG_HDACCEL} -i \"#{target_yaddif_filename}\" -vf \"vidstabdetect=stepsize=6:shakiness=8:accuracy=9:result=transform_vectors2.trf\" -f null -"

   #Stabilize using the motion vectors     
   system "\"#{FFMPEG_PATH}ffmpeg\" #{FFMPEG_HDACCEL} -i \"#{target_yaddif_filename}\" -vf \"vidstabtransform=input=transform_vectors2.trf:zoom=1:smoothing=30,unsharp=5:5:0.8:3:3:0.4, fps=25\" -c:v mpeg2video -b:v 8000k -target #{target_tv_system} -acodec copy #{metadata} \"#{target_stabilized_filename}\""
end


def check_mp4_files directory, target_path

	puts "Checking for video files ..."
	puts "-------------\n\n"

	video_files= `dir #{directory}\\*.mp4 /b /s`
	video_files= video_files + `dir #{directory}\\*.mpg /b /s`
	
	caps = video_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"
	
	index = 1
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
	   
	   input_file_name = "#{i[0]}"
	   
	   convert_chapter input_file_name, index, "#{File.dirname(input_file_name)}\\stabilized"
 
	  
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

TARGET_PATH=".\\stabilized"

tmp_vectors_filename = "#{TARGET_PATH}\\transform_vectors.trf"
target_video_filename = "#{TARGET_PATH}\\dvd_full.mp4"

print "mkdir \"#{TARGET_PATH}\""

system "mkdir \"#{TARGET_PATH}\""


PAUSE=false

puts "\nmp4_deinterlace_and_stabilize.rb - Deinterlace and stabilize mp4 video"
puts "-------------\n\n"

check_mp4_files ".", TARGET_PATH