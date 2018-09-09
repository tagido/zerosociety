#
#   process_downloads.audio.rb
#   ===================
#   Processes downloaded files with some filters
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

TARGET_MOVED_AUDIO_FILES="G:\\Downloads\\MP3\\Inbox"
DOWNLOADS_PATH="C:\\Users\\tagido\\Downloads"

PREVIEW=false

def process_downloaded_audio_file audio_file

	puts "Found file: #{audio_file} \n\n"
		
	new_file_name = "#{TARGET_MOVED_AUDIO_FILES}\\#{File.basename(audio_file)}"

	# TODO: show and add metadata
	audio_show_metadata audio_file
	
		parsed_filename = File.basename(audio_file).scan(/(.*) - (.*).mp3/)
		print parsed_filename
		begin
		author = parsed_filename[0][0]
		track_name = parsed_filename[0][1]
		rescue
		author = "UNK"
		track_name = File.basename(audio_file)
		end
		
		
		print author
		print track_name
   
		genre = "DummyGenre"
		date = "DummyDate"
		album = "DummyAlbum"
   
		#metadata = "-metadata track=1"
		metadata = "-metadata title=\"#{track_name}\" -metadata artist=\"#{author}\" -metadata genre=\"#{genre}\" -metadata date=\"#{date}\" -metadata album=\"#{album}\" -metadata track=1"

		print metadata
		
		audio_add_metadata audio_file, new_file_name, metadata
		
		audio_show_metadata new_file_name
	
	if !PREVIEW
	system "del /Q \"#{audio_file}\" "
	system "dir \"#{new_file_name}\""
	end
	
	# TODO: Call musicbrainz picard (?)
	
	# TODO: Call cover fetcher (?)
	
	# TODO: Call dbpedia (?)
end


def check_for_audio_files 

	puts "Checking for audio files ..."
	puts "-------------\n\n"

	audio_files= `dir #{DOWNLOADS_PATH}\\*.mp3\ /b /s`

	caps = audio_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	caps.each do |i|
		process_downloaded_audio_file i[0]	 
	end

end

check_for_audio_files