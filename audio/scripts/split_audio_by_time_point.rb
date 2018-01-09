#
#   split_audio_by_track_list_file.rb
#   =================================
#   Splits an audio file by using a single cut point
#   Creates multiple audio files from the original file
#
#   Can be useful for
#   - converting old vynil recordings
#   - converting old tape recordings
#   - ...
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

def convert_chapter start_time,end_time,file_index, track_name, preview


   if TARGET_FORMAT.eql? "mp3"
		#codec_options = "-codec:a libmp3lame -qscale:a 2"
		codec_options="-c:a copy"
   else
		codec_options = ""
   end
   
   metadata = "-metadata track=\"#{file_index}\""
   
   call_ffmpeg_raw "-i \"#{TARGET_FILENAME}\" -ss #{start_time} -to #{end_time} #{codec_options}  #{metadata} \"#{TARGET_FILENAME}\".point.split.#{file_index}.#{TARGET_FORMAT}", preview

end

def duration_to_seconds duration
	components = duration.split(':')
	
	return components[0].to_i * 60 + components[1].to_i
end


# TODO: automate dependencies and directories (currently hardcoded)
FFMPEG_PATH="D:\\Program Files\\ffmpeg-20180102\\bin\\"
TARGET_FILENAME=ARGV[0]
SPLIT_POINT=ARGV[1]
TARGET_FORMAT="mp3"
#TARGET_FORMAT="flac"

START_OFFSET = 0


#PREVIEW=true
PREVIEW=false

puts "split_audio_by_time_point.rb - Splits audio by time point"
puts "-------------\n\n"

puts "Splitting...\n\n"

track_name_in = TARGET_FILENAME
   
convert_chapter "00:00:00"  , SPLIT_POINT , 1, track_name_in+".point.split.1.mp3", PREVIEW
convert_chapter SPLIT_POINT , "9:59:59"  , 2, track_name_in+".point.split.2.mp3", PREVIEW

   
