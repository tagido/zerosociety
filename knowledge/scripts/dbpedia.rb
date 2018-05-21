require "dbpedia"
require 'ostruct'

Process::RLIMIT_NOFILE= 1000
def Process::getrlimit xxx
 
 x= OpenStruct.new
 
 x.first=1000
 
 x
end
  
#require 'sparql/client'

 
 #if Gem.win_platform? then 

#  else
#   DEFAULT_POOL_SIZE = Process.getrlimit(Process::RLIMIT_NOFILE).first / 4
 #  end

# Default search is by keyword:
def search_words words

	print "### Searching for #{words}...\n\n"

	x1 = Dbpedia.search(words)#.collect(&:label)
	#puts x1
	
	if x1.first.nil?
		return "NOT FOUND"
	end
	
	puts x1.first.uri
	puts x1.first.description
	#puts x1.first.categories
	print "CATs:\n"
	x1.first.categories.each do |i|
		print "#{i.label}, "
	end

	print "\n\nCLASSES:\n"
	x1.first.classes.each do |i|
		print "#{i.label}, "
	end

print "\n"

#x2=Dbpedia.search('Ham', method: 'keyword').collect(&:label)
#puts x2
end





def search_person_image person_name

	xsparqlres = Dbpedia.sparql.query("select ?person,?i where {?person foaf:name \"#{person_name}\"@en. ?person a foaf:Person. ?person <http://dbpedia.org/ontology/thumbnail> ?i}").limit(10)
	#puts xsparqlres

	# http://www.rubydoc.info/github/ruby-rdf/rdf/RDF/Query/Solution

	index = 0


	xsparqlres.each_solution do |solution|

		#puts solution.bound?(:i)
		puts "#{solution[:person]} ... #{solution[:i]}"
		return solution[:i]
		  #system "start #{solution[:i]}"
		
	  # solution.each_binding do |i|
		# puts "___ solution #{index}"
		# i.each  { |value| puts "value=#{value}" }
		# index=index+1
	  # end
	end

	return nil
end


search_words 'Mikhail Bakunin'
search_words 'Moses Hess'
search_words 'John F. Kennedy'
search_words 'Maxim Gorky'

print "### Images ...\n"

search_person_image "John F. Kennedy"
search_person_image "Robert F. Kennedy"
search_person_image "Mikhail Bakunin"

search_words ARGV[0]
imgurl = search_person_image ARGV[0]
if (imgurl.nil? == false)
	system "start #{imgurl}"
else
	print "Image not found ... #{ARGV[0]}\n"
end
