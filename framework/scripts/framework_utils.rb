#
#   framework_utils.rb
#   =============
#   Useful routines
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

require 'time'

# Wait for the spacebar key to be pressed
def wait_for_spacebar
   print "Press space to continue ...\n"
   sleep 1 while $stdin.getc != " "
end

#
# Time/Date functions
#

def conv_hhmmss_to_seconds time_string

 seconds = "#{time_string}".split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b}

 return seconds
 
end


def get_current_time_str_for_filename

	time = Time.now.getutc
	time2 = time.to_s.delete ': '

	return time2
	
end

#
# Numeric functions
#

def convert_number_locale_from_PT_to_US number_str
	
	if number_str.nil?
		return number_str
	end
	
	#puts "original: #{number_str}\n"
	
	number_str_without_commas = number_str.delete(".")
	
	number_str_without_commas.gsub! ',', '.' 
	
	#puts "conv'd: #{number_str_without_commas}\n"
	
	return number_str_without_commas
				
end


#
# Files and directories
#


def create__dir target_dir
	print "Creating directory: mkdir \"#{target_dir}\"  \n\n"
	system "mkdir \"#{target_dir}\""
end