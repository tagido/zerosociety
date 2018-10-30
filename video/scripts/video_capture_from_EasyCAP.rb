#
# video_capture_from_EasyCAP.rb
#
# Capture video from EasyCAP cheap device
#
require_relative "../../framework/scripts/framework_utils.rb"

FFMPEG_PATH="D:\\Program Files\\ffmpeg-20161210\\bin\\"
TARGET_PATH="G:.\\"

FFMPEG_HDACCEL="-hwaccel dxva2 -threads 1"
TARGET_FILENAME=ARGV[0]
TARGET_FORMAT="mpg"

#PREVIEW=true
PREVIEW=false

puts "video_capture_from_EasyCAP.rb - ..."
puts "-------------\n\n"

if TARGET_FILENAME.nil?
	puts "Usage: video_capture_from_EasyCAP.rb [target file]\n\n"
	exit -1
end

print ARGV[0]

if ARGV[0].to_s === "preview".to_s
	call_ffplay_raw "-f dshow -video_size 640x480 -framerate 25 -i video=\"USB2.0 PC CAMERA\":audio=\"EasyCAP (USB2.0 MIC)\"", false
	exit -1
end

print "### EasyCAP Capture options\n"
# Show EasyCAP capture options 
call_ffmpeg_raw  "-f dshow -list_options true -i video=\"USB2.0 PC CAMERA\" -pix_fmt yuv420p -c:v mjpeg -c:a copy -r 25",false

print "Press 'q' to stop recording ...\n"

call_ffmpeg_raw  "-f dshow -video_size 640x480 -framerate 25 -i video=\"USB2.0 PC CAMERA\":audio=\"EasyCAP (USB2.0 MIC)\" -pix_fmt yuv420p  -c:v mpeg2video -b:v 20000k -c:a copy -r 25 #{TARGET_FILENAME}.mkv", false

#system "\"#{FFMPEG_PATH}ffmpeg.exe\" #{FFMPEG_HDACCEL} -i \"#{i[0]}\" -v debug -f null - 2> \"#{i[0]}.debug.raw.log\""
   
# -pix_fmt yuv420p

# https://video.stackexchange.com/questions/21744/ffmpeg-and-converting-pixel-format-bgr24-to-yuv420p-unpredictable-garbage-outpu
# https://stackoverflow.com/questions/37088517/ffmpeg-remove-sequentially-duplicate-frames
# https://superuser.com/questions/1167958/video-cut-with-missing-frames-in-ffmpeg
# https://superuser.com/questions/436187/ffmpeg-convert-video-w-dropped-frames-out-of-sync
# https://video.stackexchange.com/questions/18220/fix-bad-files-and-streams-with-ffmpeg-so-vlc-and-other-players-would-not-crash