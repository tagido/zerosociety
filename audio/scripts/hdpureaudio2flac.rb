#
#   hdpureaudio2flac.rb
#   ===================
#   Converts a Bluray HD Pure Audio backup to FLAC lossless audio format
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

def convert_full_audio target_file,preview

   conv_command = "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"bluray:#{BLURAY_PATH}\" -map 0:1 -ac 2 \"#{target_file}\""
   #puts "conv #{start_time} .. #{end_time} \n"
   puts "#{conv_command}\n"
   puts "Running conversion...\n"
   if (preview==false)
	system "#{conv_command}\n"
   end
end

def convert_chapter tmp_file,start_time,end_time,file_index,preview
	artist="Dummy"
	album= "Dummy Album"
	date=  "2006"
	genre= "DummyGenre"

   metadata = "-metadata title=\"Track #{file_index}\" -metadata artist=\"#{artist}\" -metadata genre=\"#{genre}\" -metadata date=\"#{date}\" -metadata album=\"#{album}\" -metadata track=\"#{file_index}\""
   conv_command = "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{tmp_file}\" #{metadata} -ss #{start_time} -to #{end_time} \"#{TARGET_PATH}#{artist} - #{album} - Track #{file_index}.flac\""
   #puts "conv #{start_time} .. #{end_time} \n"
   puts "#{conv_command}\n"
   puts "Running conversion...\n"
   if (preview==false)
	system "#{conv_command}\n"
   end
end

FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
EAC3TO_PATH="D:\\Program Files (x86)\\eac3to331\\"
#BLURAY_PATH="H:"
#BLURAY_PATH="G:\\_Documentos\\Downloads\\Dummy"
BLURAY_PATH="G:\\Downloads\\Bluray\\AMY WINEHOUSE BACK TO BLACK"
TARGET_PATH=".\\"
TARGET_FILENAME="Bluray - Track "

GET_CHAPTERS_COMMAND=EAC3TO_PATH+"eac3to.exe . 1) 1: cap.txt"

# TODO: automate dependencies and directories (currently hardcoded)
# TODO: consider using a temporary FLAC file with all the audio, for faster conversion
#       for large bluray disks it spends a lot of time seeking the data

puts "hdpureaudio2flac.rb - Converts a Bluray HD Pure Audio backup to FLAC"
puts "-------------\n\n"
puts "Reading Bluray Disk structure ...\n\n"


system "\"#{EAC3TO_PATH}eac3to.exe\" \"#{BLURAY_PATH}\" 1) 1: cap.txt\""
#print "#### xpto=",xpto," \n"

stats_raw = `type cap.txt`

print "#### caps=",stats_raw," \n"

caps = stats_raw.scan(/..:..:....../)
print "caps=", caps, "\n\n"

start_str = "00:00:00.000"
index = 1

# TODO: add command/line arg
preview=false

tmp_file = "#{TARGET_PATH}BlurayFullAudioTrack.tmp.flac"

convert_full_audio tmp_file,preview

caps.each do |i|
   puts "Value of local variable is #{start_str} .. #{i}, index=#{index}/#{caps.length}"
   if (index > 1)
	if ((index-1) == caps.length) 
		# Convert until the end of the disk
		# TODO: remove (obsolete)
		convert_chapter tmp_file,start_str, "10:00:00.000", index - 1, preview
    else
		convert_chapter tmp_file,start_str, i, index - 1, preview
	end
   end
   start_str = i
   index = index + 1;
end

# Convert until the end of the disk
convert_chapter tmp_file, start_str, "10:00:00.000", index - 1, preview
