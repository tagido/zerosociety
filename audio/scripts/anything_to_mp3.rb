#
# anything_to_mp3.rb
#
#

FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
TARGET_PATH="G:.\\"
SOURCE_FILENAME=ARGV[0]
TARGET_FORMAT="mp3"

#PREVIEW=true
PREVIEW=false


# NOTE: for PSP, use 480x480px images
#
 
def add_jpg_cover_art_to_mp3 track_filename, cover_jpg_filename

    

   conv_command = "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{track_filename}\" -i \"#{cover_jpg_filename}\" -c copy -map 0 -map 1 -metadata:s:v title=\"Album cover\" -metadata:s:v comment=\"Cover (Front)\" \"#{track_filename}.cover.mp3\""
   
   puts "#{conv_command}\n"
   puts "Adding cover art to Track #{track_filename} ...\n"
   system "#{conv_command}\n"

   system "del \"#{track_filename}\""
   system "move \"#{track_filename}.cover.mp3\" \"#{track_filename}\""
   #system "del \"#{track_filename}.jpg\""
end


puts "anything_to_mp3.rb - ..."
puts "-------------\n\n"

if SOURCE_FILENAME.nil?
	puts "Usage: anything_to_mp3.rb [source files]\n\n"
	exit -1
end

puts "#{SOURCE_FILENAME}\n"

system "dir \"#{SOURCE_FILENAME}\" /b"
SOURCE_FILES= `dir \"#{SOURCE_FILENAME}\" /b`

puts "#{SOURCE_FILES}\n"

caps = SOURCE_FILES.scan(/(.*)\n/)

puts "Found files:\n #{caps} \n\n"

track_no = 1

system "mkdir mp3"

# -metadata track=\"#{track_no}\"

caps.each do |i|
   puts "Value of local variable is  #{i}\n"

   output_filename = "mp3\\#{i[0]}.mp3"
 
   system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{i[0]}\"   \"#{output_filename}\" 2>  \"mp3\\#{i[0]}.stderr.log\""
   
   track_no = track_no + 1

   add_jpg_cover_art_to_mp3 output_filename, "cover.jpg"
end

