#
#   framework_debug_common.rb
#   ===================
#   Common reporting/logging functions
#
#   Copyright (C) 2016-2018 Pedro Mendes da Silva 
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

require_relative "./framework_utils.rb"
require 'ostruct'

report_config = nil

REPORT_CONFIG = OpenStruct.new


def debug_create_log_file
   File.open(REPORT_CONFIG.report_file, 'w') { |file| file.write("#############################################\n") }
end


def debug_print string
   File.open(REPORT_CONFIG.report_file, 'a') { |file| file.write(string) }
   print string
end

def debug_print_section_break
    debug_print "\n---X---X---X---X---X---X---X---X---X---\n\n"
end

def debug_system_return_output command
   system "#{command} > #{REPORT_CONFIG.tmp_stdout_file} 2> #{REPORT_CONFIG.tmp_stderr_file}"
   
   output1 = `copy #{REPORT_CONFIG.tmp_stdout_file}+#{REPORT_CONFIG.tmp_stderr_file} #{REPORT_CONFIG.tmp_stdout_and_stderr_file}` 
   
   output = `type #{REPORT_CONFIG.tmp_stdout_and_stderr_file}`
   
   #system "cat #{TMP_STDOUT_FILE} #{TMP_STDERR_FILE} >> #{REPORT_FILE}"
   
   debug_print "#{output}"
   
   return output
end



def debug_init report_file_name
	
	report_file = report_file_name

	REPORT_CONFIG.report_file = report_file_name
	REPORT_CONFIG.tmp_stdout_file = "#{report_file_name}.tmp.stdout.log"
	REPORT_CONFIG.tmp_stderr_file = "#{report_file_name}.tmp.stderr.log"
	REPORT_CONFIG.tmp_stdout_and_stderr_file = "#{report_file_name}.tmp.stdout_and_stderr.log"
	
end

