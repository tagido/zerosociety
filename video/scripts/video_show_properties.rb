#
# video_show_properties.rb
#
# Checks for errors in video streams

FFMPEG_PATH="D:\\Program Files\\ffmpeg-20161210\\bin\\"
TARGET_PATH="G:.\\"

FFMPEG_HDACCEL="-hwaccel dxva2 -threads 1"
SOURCE_FILENAME=ARGV[0]
TARGET_FORMAT="mpg"

#PREVIEW=true
PREVIEW=false

puts "video_show_properties.rb - ..."
puts "-------------\n\n"

if SOURCE_FILENAME.nil?
	puts "Usage: video_show_properties.rb [source files]\n\n"
	exit -1
end

puts "#{SOURCE_FILENAME}\n"

system "dir \"#{SOURCE_FILENAME}\" /b"
SOURCE_FILES= `dir \"#{SOURCE_FILENAME}\" /b`

puts "#{SOURCE_FILES}\n"

caps = SOURCE_FILES.scan(/(.*)\n/)

puts "Found files:\n #{caps} \n\n"

track_no = 1

caps.each do |i|
   #puts "Value of local variable is  #{i}\n"
 
   system "\"#{FFMPEG_PATH}ffmpeg.exe\"  -i \"#{i[0]}\" "
   #-f null - 2> \"#{i[0]}.debug.raw.log\""
   
   track_no = track_no + 1
end

