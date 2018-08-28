#
# video_extract_thumbnails.rb
#
# Checks for errors in video streams

require_relative "../../framework/scripts/framework_utils.rb"

FFMPEG_HDACCEL="-hwaccel dxva2 -threads 1"
SOURCE_FILENAME=ARGV[0]


#PREVIEW=true
PREVIEW=false

puts "video_extract_thumbnails.rb - ..."
puts "-------------\n\n"

if SOURCE_FILENAME.nil?
	puts "Usage: video_extract_thumbnails.rb [source files]\n\n"
	exit -1
end

puts "#{SOURCE_FILENAME}\n"

system "dir \"#{SOURCE_FILENAME}\" /b"
SOURCE_FILES= `dir \"#{SOURCE_FILENAME}\" /b`

puts "#{SOURCE_FILES}\n"

caps = SOURCE_FILES.scan(/(.*)\n/)

puts "Found files:\n #{caps} \n\n"

track_no = 1

  options=OpenStruct.new
  options.scale = "1280:720"
  options.fps = "1/60"
#  options.subtitles = "Putin2018.pt.srt"

caps.each do |i|
   #puts "Value of local variable is  #{i}\n"
 
   # TODO: extrair nos momentos das legendas
 
   #system "\"#{FFMPEG_PATH}ffmpeg.exe\" #{FFMPEG_HDACCEL} -i \"#{i[0]}\" -v debug -f null - 2> \"#{i[0]}.debug.raw.log\""
   video_extract_jpg_thumbnails i[0],options
   
   track_no = track_no + 1
end


# TODO: merge thumbnails in a single image
# G:\Downloads\Viagens\Artico2018\SDV_2054.MP4.images>"d:\Program Files\ImageMagick-7.0.2-Q16\magick.exe" montage -geometry 256x144+0+0 img* out.jpg"
