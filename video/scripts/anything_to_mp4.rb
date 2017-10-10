#
# anything_to_mp4.rb
#
#

FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
TARGET_PATH="G:.\\"
SOURCE_FILENAME=ARGV[0]
TARGET_FORMAT="mp4"

#PREVIEW=true
PREVIEW=false

puts "anything_to_mp4.rb - ..."
puts "-------------\n\n"

if SOURCE_FILENAME.nil?
	puts "Usage: anything_to_mp4.rb [source files]\n\n"
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
   puts "Value of local variable is  #{i}\n"
 
   system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{i[0]}\" -metadata track=\"#{track_no}\"  \"#{i[0]}\".mp4"
   
   track_no = track_no + 1
end

