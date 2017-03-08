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


# Wait for the spacebar key to be pressed
def wait_for_spacebar
   print "Press space to continue ...\n"
   sleep 1 while $stdin.getc != " "
end



def conv_hhmmss_to_seconds time_string

 seconds = "#{time_string}".split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b}

 return seconds
 
end