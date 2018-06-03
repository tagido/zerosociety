require 'musicbrainz'
require_relative './cue_file_common.rb'


class MusicBrainzAlbumMetadata < AlbumMetadata


# https://github.com/dwo/musicbrainz-ruby
#
# https://musicbrainz.org/doc/Development/XML_Web_Service/Version_2
#

# Returns hashie mashup objects
#   - https://github.com/intridea/hashie

	def get_metadata_from_music_brainz album_mbid

		brainz = MusicBrainz::Client.new(:username => 'username',
                                 :password => 'password')
							


		# Find an artist by id, include artist relations
		#res = brainz.artist(:mbid => '45d15468-2918-4da4-870b-d6b880504f77', :inc => 'artist-rels')
		#puts "res=#{res}\n"

		# Search for artists with the query 'Diplo'
		#res = brainz.release(:query => album_mbid, :inc=>'isrcs')
		#puts "res=#{res}\n"

		#release_list = res.release_list
		#artist_credit =""

		#puts "  count=#{release_list[:count]}\n"
		#puts "  count=#{release_list[:count]}\n"


		release2 = brainz.release(:mbid => album_mbid, :inc => 'recordings+artists+labels')
		puts "release2=#{release2}\n"

		name =   release2.release.artist_credit.name_credit.artist.name 
		#name = "UNK"
		title =  release2.release.title
		status = release2.release.status
		medium = release2.release.medium_list.medium
		date = release2.release.date
		year = date[0,4]
		begin
		label = release2.release.label_info_list.label_info.label.name
		rescue
		label = "UNK"
		end
		
		puts "### name=#{name} title=#{title} status=#{status} id=#{album_mbid}\n"
		puts "###      medium=#{medium} \n"
		puts "###      format=#{medium.format} tracks=#{medium.track_list[:count]} \n"
		puts "###      date=#{date} year=#{year}\n\n"
		medium.track_list.track.each do |i|
		 #number="1" 
		#			  position="1" 
		#			  recording
		  puts "  #{i.position} recording id=#{i.id} length=#{i.recording[:length]} title=#{i.recording.title} \n"
			track = TrackMetadata.new i.position, i.recording.title, i.recording[:length].to_i / 1000
			add_track track
		end
		
		@artist = name
		@title = title
		@year = year
		@label = label
		
		@ref_url = "https://musicbrainz.org/release/#{album_mbid}"
	    
	end

end

album_mbid = ARGV[0]

xpto = MusicBrainzAlbumMetadata.new

xpto.get_metadata_from_music_brainz album_mbid 


xpto.export_to_wiki

