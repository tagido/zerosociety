require_relative "../../framework/scripts/framework_utils.rb"

	def seconds_to_min_secs_str total_seconds
		seconds =  "%02d" % (total_seconds % 60)
		minutes =  "%02d" % (total_seconds / 60)
		return "#{minutes}:#{seconds}"
	end

class TrackMetadata
	attr_accessor :track_index,	:track_name, :track_duration, :disk_index

	def initialize track_index,	track_name, track_duration
		@track_index = track_index	
		@track_name = track_name 
		@track_duration = track_duration
		@ref_url = "UNK"
		@disk_index = 1	
	end
	

	
	def dump
		aux_index = "%02d" % track_index
		print " -- #{@disk_index}.#{aux_index} - #{track_name}  #{track_name.encoding} (#{seconds_to_min_secs_str(@track_duration)})  \n"
	end
	
	def get_wiki_string
		<<-END_WIKI
# "#{track_name}"  - #{seconds_to_min_secs_str(@track_duration)}		
		END_WIKI
	end
	
end

class AlbumMetadata

	attr_accessor :track_array,	:n_tracks, :artist, :title, :total_duration, :year

	def initialize 
		@track_array = Array.new(0)
		@n_tracks = 0
		@artist = "UNK"
		@title = "UNK"
		@total_duration = 0
		@year = "UNK"
		@label = "UNK"
		
		@n_discs = 1
	end

	def add_track track
		
		if track.disk_index > @n_discs
			@n_discs = track.disk_index
		end
		
		@track_array = @track_array.push track	
		@n_tracks = @n_tracks + 1
		
		@total_duration = @total_duration + track.track_duration
		
		#dump
	end
	
	def dump
		print "AlbumMetadata::dump  @n_tracks = #{@n_tracks} (duration=#{seconds_to_min_secs_str(@total_duration)})\n"
		print "#{artist} - #{title}\n"
		#print "@track_array=#{@track_array}\n"
		@track_array.each do |track|
			track.dump
		end
	end
	
	def duration_to_seconds duration
		components = duration.split(':')
		
		return components[0].to_i * 60 + components[1].to_i
	end

	def HMS_duration_to_seconds duration
		components = duration.split(':')
		
		return components[0].to_i * 60 + components[1].to_i
	end
	
	def parse_track_list__cue_file tracks_text_file

	  #tracks_list = tracks_text_file.scan(/([0-9][0-9]+\:[0-9][0-9]+\:[0-9][0-9])+/)

	  tracks_list = tracks_text_file.scan(/TRACK ([0-9][0-9]) AUDIO\n    TITLE \"(.*)\"(\n    PERFORMER \"(.*)\")?(\n    REM (.*))?\n    INDEX 01 ([0-9][0-9]+\:[0-9][0-9]+\:[0-9][0-9])/)
	  #  TRACK 01 AUDIO
	  #  TITLE "É o mar que nos chama"
	  #  INDEX 01 00:00:00
	  
	  album_title = tracks_text_file.scan(/TITLE \"(.*)\"\nFILE/)
	  album_artist = tracks_text_file.scan(/PERFORMER \"(.*)\"\nTITLE/)
	  album_date = tracks_text_file.scan(/DATE ([0-9][0-9][0-9][0-9])/)
	  
	  print "tracks_list= #{tracks_list}\n\n"
	  print "album_title = #{album_title}\n" 
	  print "album_artist = #{album_artist}\n" 
	  print "album_date = #{album_date}\n" 

	  @artist = album_artist[0][0]
	  @title = album_title[0][0]
	  if !album_date.nil? && (album_date.length > 0) 
		@year = album_date[0][0]
	  end
	  
	  return tracks_list
	end

	def parse_cue_file filename	
		#stats_raw =  File.read TRACKLIST_FILENAME #`type \"#{TRACKLIST_FILENAME}\"`
		stats_raw =  File.open(filename, "r:UTF-8", &:read)

		puts "Splitting...\n\n"

		puts stats_raw
		tracks = parse_track_list__cue_file stats_raw
		
		print "tracks= #{tracks}\n\n"

		start_str = "0"
		index = 1

		next_position = 0

		cue_skiped_first = false
		accum_duration = 0
		
		track_index = -1
		track_name = nil
		track_accum_duration = -1
		
		tracks.each do |i|

			track_accum_duration = i[6]
		   
			# mode=cue
			puts "Parsed track info  .. #{i[0]}"
			   
			if (not cue_skiped_first)
				# first item
				cue_skiped_first = true
				accum_duration = 0
				
				# save stuff for the next iteration
				track_index = i[0]
				track_name = i[1]
				next
			end
			   
			duration = HMS_duration_to_seconds track_accum_duration
			   
			end_position = duration - accum_duration + next_position
			   
			puts "Track #{index} #{track_name} interval: #{next_position} .. #{end_position} (s) \t\t(duration=#{(duration-accum_duration)/60.0} min)"
			if ((duration > 0) )
					#convert_chapter next_position  , end_position , index, track_name
				track = TrackMetadata.new index,	track_name, (duration-accum_duration)
				
				add_track track
			end
			   
			next_position = end_position 
			   
			accum_duration = end_position
			   
			index = index + 1
		   
		    # save stuff for the next iteration
		    track_index = i[0]
			track_name = i[1]


		end # do
		
		last_track_duration = "3:08"
		
		if last_track_duration.nil?
		
			duration = HMS_duration_to_seconds("74:00:00") - HMS_duration_to_seconds(track_accum_duration)
			   
			end_position = duration - accum_duration + next_position
		else
			duration = HMS_duration_to_seconds(last_track_duration)
		end
		
		track = TrackMetadata.new index,track_name, duration				
		add_track track
		#convert_chapter next_position  , duration_to_seconds("99:59") , index, track_name
	end
	
	
	# https://infinum.co/the-capsized-eight/multiline-strings-ruby-2-3-0-the-squiggly-heredoc
	def get_wiki_album_infobox
		
		album_type = "estúdio"
		#album_type = "compilação"
		
		#pubhisher = "EMI"
		#publisher = "Fundação Jorge Álvares"
		
		#more_artists = "[[Yanan]]" 
		more_artists=""
		if more_artists.nil?
			more_artists = ""
		end
	
		 <<-END_WIKI
		{{Info/Álbum
			 |nome          = #{@title}
			 |tipo          = #{album_type}
			 |artista       = [[#{@artist}]] #{more_artists}
			 |capa          = 
			 |lançado       = [[#{@year}]]
			 |gênero        = [[Música popular portuguesa]]
			 |duração       = #{seconds_to_min_secs_str(@total_duration)} [[minuto|min]]
			 |gravadora     = [[#{@label}]]
			 |idioma        = [[Língua portuguesa|Português]]
			 |produtor      = 
			}}
		END_WIKI
	end
	
	def get_wiki_album_article_header
		
		#refs_url = "https://www.discogs.com/R%C3%A3o-Kyao-Yanan-Porto-Interior/release/5195739"
		
		refs_url = @ref_url
		
		#tmp_title = "#{@artist} - #{@title}"
		tmp_source = "MusicBrainz"
		tmp_title = "Release \"#{@title}\" by #{@artist} - MusicBrainz"
		
		 <<-END_WIKI
	'''''#{@title}''''' é um álbum de [[#{@artist}]], editado em [[#{@year} na música|#{@year}]].
	      <ref name="Ref_01">
		  {{Citar periódico 
		  |autor= |data= |url=#{refs_url} |titulo=#{tmp_title} |publicado=#{tmp_source} |acessodata=#{Time.now}}}</ref>
		 END_WIKI
	end
	
	def get_wiki_album_article_footer
		 <<-END_WIKI

		{{Referências}}

		{{Esboço-álbum}}
		{{Portal3|Portugal|Música portuguesa}}

		[[Categoria:Álbuns de #{@year}]]
		[[Categoria:Álbuns de #{@artist}]]
		[[Categoria:Álbuns em língua portuguesa]]
		END_WIKI
	end
	
	def export_to_wiki
		print "\n#{title} (álbum de #{artist})\n\n"
		#print "AlbumMetadata::dump  @n_tracks = #{@n_tracks} (duration=#{seconds_to_min_secs_str(@total_duration)})\n"
		print get_wiki_album_infobox
		print get_wiki_album_article_header
		print "== Alinhamento ==\n"
		current_disc = 1

		@track_array.each do |track|
		
			# Handle multi-disc album
			if @n_discs > 1 and current_disc <=@n_discs and track.disk_index == current_disc
				print "=== CD #{current_disc} ===\n"
				current_disc = current_disc + 1
			end
			
			print track.get_wiki_string
		end
		print get_wiki_album_article_footer
	end
	
end

TRACKLIST_FILENAME=ARGV[0]

puts ".cue track list utils"
puts "-------------\n\n"

if false

album = AlbumMetadata.new
album.parse_cue_file TRACKLIST_FILENAME
album.dump

album.export_to_wiki

#parse_track_list__cue_file stats_raw


end