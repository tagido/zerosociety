#
#   images_to_meme.rb
#   ==================
#   Converts a set of images to a meme
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

puts "images_to_meme.rb - Converts "
puts "-------------\n\n"

# TODO: optionally get metadata from the command line

metadata = OpenStruct.new

if ARGV[0].nil?
	metadata.title = "Unknown Title"
else
	metadata.title = ARGV[0]
end
metadata.author = "Desconhecido"

# TODO: font and box size proportional to the image size
#       or resizing original file
#       or adding extra space to the left of the image
# target dirs

image_add_text ARGV[0], ARGV[0]+"_meme.png", "Oh, mar salgado, quanto do teu sal, sao lagrimas\n de portugal"

