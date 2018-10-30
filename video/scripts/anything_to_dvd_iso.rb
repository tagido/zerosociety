#
#   anything_to_dvd_iso.rb
#   ===================
#   Convert a video to a dvd iso
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
#

require_relative "../../framework/scripts/framework_utils.rb" 
require_relative "../../framework/scripts/framework_debug_common.rb"



# http://dvdauthor.sourceforge.net/doc/dvdauthor.html

preview = false
input_file = ARGV[0]
subtitles_input_file = ARGV[1]

target_dir = ".\\tmp.dvd"
target_tmp_mpg_video_file = "#{target_dir}\\video.mpg"
target_tmp_dir = "#{target_dir}\\dvd_vobs_tmp_source"
target_iso_dir = "#{target_dir}\\iso"
target_iso_file = "#{target_iso_dir}\\dvd.iso"

debug_init "#{target_dir}\\anything_to_dvd_iso.log"

# rd target_dir

#call_ffmpeg_raw "-i \"#{input_file}\" -aspect 16:9 -target pal-dvd tmp.dvd\\video.mpg", preview

# export VIDEO_FORMAT=PAL


DVD_AUTHOR_PATH="d:\\Downloads\\dd-0.6beta3\\dvdauthor\\dvdauthor.exe"
MKISOFS_PATH="d:\\Downloads\\dd-0.6beta3\\mkisofs.exe"

dvd_author_project_file = "D:\\Mais documentos\\Projectos\\Ruby scripts\\zerosociety\\video\\scripts\\dvdauthor.single_file.xml"


delete_file "#{target_tmp_dir}"

create_dir target_dir
create_dir target_tmp_dir

# backup previous video conversion, just in case ...
system "xcopy /Y \"#{target_tmp_mpg_video_file}\" \"#{target_tmp_mpg_video_file}.bak\"" 

call_ffmpeg_raw "#{FFMPEG_DEFAULT_HDACCEL} -i \"#{input_file}\" -vf \"subtitles=#{subtitles_input_file}:force_style='Fontsize=32'\" -aspect 16:9 -target pal-dvd #{target_tmp_mpg_video_file}", preview

system "xcopy /Y \"#{dvd_author_project_file}\" \"#{target_dir}\"" 

output = debug_system_return_output "#{DVD_AUTHOR_PATH} -o #{target_tmp_dir} -x #{target_dir}\\dvdauthor.single_file.xml"

# https://linux.die.net/man/8/mkisofs
create_dir target_iso_dir
output = debug_system_return_output "#{MKISOFS_PATH} -dvd-video -o \"#{target_iso_file}\" \"#{target_tmp_dir}\""


