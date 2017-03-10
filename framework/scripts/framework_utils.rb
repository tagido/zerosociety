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
require 'ostruct'


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
# Zipping and Unzipping
#

# TODO : automate dependencies and port to Linux, MacOS
#
# Refs: https://sevenzip.osdn.jp/chm/cmdline/switches/method.htm

SEVENZIP_PATH="\"c:\\Program Files\\7-Zip\\7z.exe\""

def unzip_archive source_archive, target_dir

	#print "#{SEVENZIP_PATH} x \"#{source_archive}\" -y -o\"#{target_dir}\" \n"

	result = system "#{SEVENZIP_PATH} x \"#{source_archive}\" -y -o\"#{target_dir}\""

	return result
end

def zip_dir_to_archive source_dir, target_archive

	system "del #{target_archive} /Q"

	# Workaround for EPUB as described in https://sourceforge.net/p/sevenzip/feature-requests/1212/
	
	system "ren \".\\#{source_dir}\\mimetype\" !mimetype"
	
	system "#{SEVENZIP_PATH} a \"#{target_archive}\" -mx0 -r -y \".\\#{source_dir}\\mimetype\""
	
	result = system "#{SEVENZIP_PATH} a \"#{target_archive}\" -mx0 -r -y \".\\#{source_dir}\\*\" -x!\".\\#{source_dir}\\mimetype\""

	system "#{SEVENZIP_PATH} rn \"#{target_archive}\" !mimetype mimetype"
	
	system "ren \".\\#{source_dir}\\!mimetype\" mimetype"
	
	return result
end

#
# Resources
#

RESOURCES_MANAGER = OpenStruct.new

def resources_init current_code_file
	
	RESOURCES_MANAGER.root_dir = "#{File.dirname(current_code_file)}\\resources"
	
end

def resources_get_root_dir
	
	return RESOURCES_MANAGER.root_dir

end
	
def resources_get_subdir subdir_name

	return "#{RESOURCES_MANAGER.root_dir}\\#{subdir_name}"

end

#
# Files and directories
#


def create_dir target_dir
	print "Creating directory: mkdir \"#{target_dir}\"  \n\n"
	system "mkdir \"#{target_dir}\""
	system "del \"#{target_dir}\"\\*.* /Q"
end

def copy_files_to_target_dir files, target_dir
	print "Copying files: #{files} to \"#{target_dir}\"  \n\n"
	system "xcopy #{files} \"#{target_dir}\""
end

def dump_file_from_string target_filename, string

	print "Writing file: #{target_filename}\"  ...\n\n"

	File.open(target_filename, 'w') { 
			|file| file.write(string)
	}
	
end