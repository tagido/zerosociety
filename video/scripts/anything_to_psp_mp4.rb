#
#   anything_to_psp_mp4.rb
#   ===================
#   Convert a video to psp_mp4
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


preview = false
input_file = ARGV[0]
#subtitles_input_file = ARGV[1]

target_dir = ".\\tmp.dvd"
target_tmp_mpg_video_file = "#{target_dir}\\video.mpg"
target_tmp_dir = "#{target_dir}\\dvd_vobs_tmp_source"
target_iso_dir = "#{target_dir}\\iso"
target_iso_file = "#{target_iso_dir}\\dvd.iso"

debug_init "#{target_dir}\\anything_to_psp_mp4.log"

# rd target_dir
output_file = "#{input_file}_PSP.mp4" 

#https://askubuntu.com/questions/170680/ffmpeg-avconv-the-psp-option-no-longer-works-on-sony-walkman
#
#
# -profile:v main -level 3 -x264opts ref=3:b-pyramid=none:weightp=1

profile_options="-profile:v main -level 3 -x264opts ref=3:b-pyramid=none:weightp=1"

output_resolution="-vf scale=480:272,fps=25" 

#call_ffmpeg_raw "-i \"#{input_file}\" -aspect 16:9 -target pal-dvd tmp.dvd\\video.mpg", preview
#call_ffmpeg_raw "-y -i \"#{input_file}\"  -codec:a aac -map 0:0 -map 0:1 -s 720x480 -r 25 -an -pass 1 -codec:v libx264 -bitrate 1400 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -refs 2 -me_method umh -me_range 17 -subq 1 -trellis 0 -coder 1 -bf 7 -b_strategy 1 -threads 0 -g 300 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4   -map 0:1 \"#{output_file}\"", preview

call_ffmpeg_raw "-y -i \"#{input_file}\"  -codec:a aac -codec:v libx264 -profile:v main -level 3 -x264opts ref=3:b-pyramid=none:weightp=1 -map 0:0 -map 0:1 #{output_resolution} \"#{output_file}\"", preview

# burn-in subtitles
#  ...
# ...

# generate thumbnail 
#  - jpg: 160x120
# rename jpg to .THM

# copy to PSP (?)



# tmp:instagram
# ffmpeg -i input0 -i input1 -filter_complex vstack output
#
#
#-pix_fmt yuv420p
#extra_options_igtv = "-framerate 30"
#output_resolution="-vf scale=272:480,fps=25" 