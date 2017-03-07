#
#   vcd2mp3.rb
#   ===================
#   Converts a VCD (Video-CD) backup to mp3 audio format 
#  (multiple audio output files are created, one for each original track)
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
#

# TODO: automate dependencies and directories (currently hardcoded)
FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
EAC3TO_PATH="D:\\Program Files (x86)\\eac3to331\\"
BLURAY_PATH="G:."
TARGET_PATH="G:.\\"
SOURCE_DRIVE=ARGV[0]
TARGET_FILENAME=ARGV[1]


puts "vcd2mp3.rb - Converts a VCD to mp3 (audio only)"
puts "----------------------------------------------------\n\n"

MPEG1_FILES= `dir #{SOURCE_DRIVE}\\MPEGAV\\AVSEQ??.DAT\ /b /s`


caps = MPEG1_FILES.scan(/AVSEQ../)

puts "Found files:\n #{caps} \n\n"

track_no = 1

caps.each do |i|
   #puts "Value of local variable is #{start_str} .. #{i}"

   system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{SOURCE_DRIVE}\\MPEGAV\\#{i}.DAT\" -metadata track=\"#{track_no}\"  -codec:a libmp3lame -qscale:a 2 \"#{TARGET_FILENAME}\".vcd.#{track_no}.mp3"
   
   track_no = track_no + 1
end
