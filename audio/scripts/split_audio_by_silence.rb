#
#   split_audio_by_silence.rb
#   =========================
#   Splits an audio file by searching for silence intervals
#   Creates multiple audio files from the original file
#
#   Can be useful for
#   - converting old vynil recordings
#   - converting old tape recordings
#   - ...
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



def convert_chapter start_time,end_time,file_index
	artist="DJ Estaline"
	album= "Martelos"
	date=  "2006"
	genre= "Hip-Hop"

   #start_time = start_time - 0.25
   #end_time = end_time + 0.25

   if TARGET_FORMAT.eql? "mp3"
		codec_options = "-codec:a libmp3lame -qscale:a 2"
   else
		codec_options = ""
   end
   
   #metadata = "-metadata title=\"Track #{file_index}\" -metadata artist=\"#{artist}\" -metadata genre=\"#{genre}\" -metadata date=\"#{date}\" -metadata album=\"#{album}\" -metadata track=\"#{file_index}\""
   metadata = "-metadata title=\"Track #{file_index}\" -metadata track=\"#{file_index}\""
   #MP3 conv_command = "\"#{FFMPEG_PATH}ffmpeg.exe\"  -i \"#{TARGET_FILENAME}\" -ss #{start_time} -to #{end_time} -codec:a libmp3lame -qscale:a 2 #{metadata} \"#{TARGET_FILENAME}\".split.#{file_index}.#{TARGET_FORMAT}"
   conv_command = "\"#{FFMPEG_PATH}ffmpeg.exe\"  -i \"#{TARGET_FILENAME}\" -ss #{start_time} -to #{end_time} #{codec_options}  #{metadata} \"#{TARGET_FILENAME}\".split.#{file_index}.#{TARGET_FORMAT}"
   #puts "conv #{start_time} .. #{end_time} \n"
   puts "#{conv_command}\n"
   puts "Running conversion...\n"
   system "#{conv_command}\n"
end

# TODO: automate dependencies and directories (currently hardcoded)
FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
EAC3TO_PATH="D:\\Program Files (x86)\\eac3to331\\"
TARGET_PATH="G:.\\"
TARGET_FILENAME=ARGV[0]
#TARGET_FORMAT="mp3"
TARGET_FORMAT="flac"
SILENCE_FILENAME="#{TARGET_FILENAME}.silence.txt"

#NOISE_TOLERANCE="-30dB"
#SILENCE_MINIMUM_INTERVAL="2"

NOISE_TOLERANCE="-8dB"
SILENCE_MINIMUM_INTERVAL="4"

REUSE_PREVIOUS_SILENCE_FILE=false

#PREVIEW=true
PREVIEW=false


# TODO: mostrar sempre a previsão e perguntar se quer prosseguir
# TODO: "simular" várias previões com parâmetros diferentes, tentar encontrar uma que dê um nº razoável de pistas e durações

puts "split_audio_by_silence.rb - Splits audio by silence"
puts "-------------\n\n"
puts "Searching for silence ...\n\n"

if (!REUSE_PREVIOUS_SILENCE_FILE)
	# detect silence intervals
	system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{TARGET_FILENAME}\"  -af silencedetect=noise=#{NOISE_TOLERANCE}:d=#{SILENCE_MINIMUM_INTERVAL} -f null - 2> \"#{SILENCE_FILENAME}\""
end

puts "Silences found:\n\n"

stats_raw =  `type \"#{SILENCE_FILENAME}\"`

puts "Splitting...\n\n"

puts stats_raw

#system "\"#{FFMPEG_PATH}ffmpeg.exe\" -ss #{SILENCE_START} -t #{DURATION}  -i \"#{TARGET_FILENAME}\" -codec:a libmp3lame -qscale:a 2 \"#{TARGET_FILENAME}\".1.mp3"


silence_end_list = stats_raw.scan(/silence_end: -?([0-9]+\.[0-9])+/)
silence_start_list = stats_raw.scan(/silence_start: -?([0-9]+\.[0-9])+/)

print "ends=", silence_end_list, "\n\n"
print "stas=", silence_start_list, "\n\n"

start_str = "0"
index = 1

silence_start_list.each do |i|
   silence_end = silence_end_list[index-1]
   
   #puts "silence_end=#{silence_end}"
   
   if (silence_end )
    silence_end = silence_end[0]
   else
    silence_end = -1
   end
   
   #puts "silence_end=#{silence_end}"
   
   puts "Value of silence interval is  .. #{i[0]} - #{silence_end} (s)"
   duration = i[0].to_i - start_str.to_i
   puts "Track #{index} interval: #{start_str}-#{i[0]} (s) \t\t(duration=#{duration} s)"
   if (!PREVIEW && (duration > 0) )
	if (index == silence_start_list.length) 
		# Convert until the end of the file
		convert_chapter start_str, "10000000.000", index
    else
		convert_chapter start_str, i[0], index
	end
   end
   start_str = silence_end
   index = index + 1;
end

if (!PREVIEW)
	# Convert until the end of the file (needed when there is no silence at the end)
	convert_chapter start_str, "10000000.000", index
end