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
	
	number_str_without_commas = number_str.deletedelete(".")
	
	number_str_without_commas.gsub! ',', '.' 
	
	#puts "conv'd: #{number_str_without_commas}\n"
	
	return number_str_without_commas
				
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
# Mime-types
#

def get_mime_type_from_extension filename

	get_mime = {
    ".323" => "text/h323",
    ".3g2" => "video/3gpp2",
    ".3gp" => "video/3gpp",
    ".3gp2" => "video/3gpp2",
    ".3gpp" => "video/3gpp",
    ".7z" => "application/x-7z-compressed",
    ".aa" => "audio/audible",
    ".AAC" => "audio/aac",
    ".aaf" => "application/octet-stream",
    ".aax" => "audio/vnd.audible.aax",
    ".ac3" => "audio/ac3",
    ".aca" => "application/octet-stream",
    ".accda" => "application/msaccess.addin",
    ".accdb" => "application/msaccess",
    ".accdc" => "application/msaccess.cab",
    ".accde" => "application/msaccess",
    ".accdr" => "application/msaccess.runtime",
    ".accdt" => "application/msaccess",
    ".accdw" => "application/msaccess.webapplication",
    ".accft" => "application/msaccess.ftemplate",
    ".acx" => "application/internet-property-stream",
    ".AddIn" => "text/xml",
    ".ade" => "application/msaccess",
    ".adobebridge" => "application/x-bridge-url",
    ".adp" => "application/msaccess",
    ".ADT" => "audio/vnd.dlna.adts",
    ".ADTS" => "audio/aac",
    ".afm" => "application/octet-stream",
    ".ai" => "application/postscript",
    ".aif" => "audio/x-aiff",
    ".aifc" => "audio/aiff",
    ".aiff" => "audio/aiff",
    ".air" => "application/vnd.adobe.air-application-installer-package+zip",
    ".amc" => "application/x-mpeg",
    ".application" => "application/x-ms-application",
    ".art" => "image/x-jg",
    ".asa" => "application/xml",
    ".asax" => "application/xml",
    ".ascx" => "application/xml",
    ".asd" => "application/octet-stream",
    ".asf" => "video/x-ms-asf",
    ".ashx" => "application/xml",
    ".asi" => "application/octet-stream",
    ".asm" => "text/plain",
    ".asmx" => "application/xml",
    ".aspx" => "application/xml",
    ".asr" => "video/x-ms-asf",
    ".asx" => "video/x-ms-asf",
    ".atom" => "application/atom+xml",
    ".au" => "audio/basic",
    ".avi" => "video/x-msvideo",
    ".axs" => "application/olescript",
    ".bas" => "text/plain",
    ".bcpio" => "application/x-bcpio",
    ".bin" => "application/octet-stream",
    ".bmp" => "image/bmp",
    ".c" => "text/plain",
    ".cab" => "application/octet-stream",
    ".caf" => "audio/x-caf",
    ".calx" => "application/vnd.ms-office.calx",
    ".cat" => "application/vnd.ms-pki.seccat",
    ".cc" => "text/plain",
    ".cd" => "text/plain",
    ".cdda" => "audio/aiff",
    ".cdf" => "application/x-cdf",
    ".cer" => "application/x-x509-ca-cert",
    ".chm" => "application/octet-stream",
    ".class" => "application/x-java-applet",
    ".clp" => "application/x-msclip",
    ".cmx" => "image/x-cmx",
    ".cnf" => "text/plain",
    ".cod" => "image/cis-cod",
    ".config" => "application/xml",
    ".contact" => "text/x-ms-contact",
    ".coverage" => "application/xml",
    ".cpio" => "application/x-cpio",
    ".cpp" => "text/plain",
    ".crd" => "application/x-mscardfile",
    ".crl" => "application/pkix-crl",
    ".crt" => "application/x-x509-ca-cert",
    ".cs" => "text/plain",
    ".csdproj" => "text/plain",
    ".csh" => "application/x-csh",
    ".csproj" => "text/plain",
    ".css" => "text/css",
    ".csv" => "text/csv",
    ".cur" => "application/octet-stream",
    ".cxx" => "text/plain",
    ".dat" => "application/octet-stream",
    ".datasource" => "application/xml",
    ".dbproj" => "text/plain",
    ".dcr" => "application/x-director",
    ".def" => "text/plain",
    ".deploy" => "application/octet-stream",
    ".der" => "application/x-x509-ca-cert",
    ".dgml" => "application/xml",
    ".dib" => "image/bmp",
    ".dif" => "video/x-dv",
    ".dir" => "application/x-director",
    ".disco" => "text/xml",
    ".dll" => "application/x-msdownload",
    ".dll.config" => "text/xml",
    ".dlm" => "text/dlm",
    ".doc" => "application/msword",
    ".docm" => "application/vnd.ms-word.document.macroEnabled.12",
    ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    ".dot" => "application/msword",
    ".dotm" => "application/vnd.ms-word.template.macroEnabled.12",
    ".dotx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.template",
    ".dsp" => "application/octet-stream",
    ".dsw" => "text/plain",
    ".dtd" => "text/xml",
    ".dtsConfig" => "text/xml",
    ".dv" => "video/x-dv",
    ".dvi" => "application/x-dvi",
    ".dwf" => "drawing/x-dwf",
    ".dwp" => "application/octet-stream",
    ".dxr" => "application/x-director",
    ".eml" => "message/rfc822",
    ".emz" => "application/octet-stream",
    ".eot" => "application/octet-stream",
    ".eps" => "application/postscript",
    ".etl" => "application/etl",
    ".etx" => "text/x-setext",
    ".evy" => "application/envoy",
    ".exe" => "application/octet-stream",
    ".exe.config" => "text/xml",
    ".fdf" => "application/vnd.fdf",
    ".fif" => "application/fractals",
    ".filters" => "Application/xml",
    ".fla" => "application/octet-stream",
    ".flr" => "x-world/x-vrml",
    ".flv" => "video/x-flv",
    ".fsscript" => "application/fsharp-script",
    ".fsx" => "application/fsharp-script",
    ".generictest" => "application/xml",
    ".gif" => "image/gif",
    ".group" => "text/x-ms-group",
    ".gsm" => "audio/x-gsm",
    ".gtar" => "application/x-gtar",
    ".gz" => "application/x-gzip",
    ".h" => "text/plain",
    ".hdf" => "application/x-hdf",
    ".hdml" => "text/x-hdml",
    ".hhc" => "application/x-oleobject",
    ".hhk" => "application/octet-stream",
    ".hhp" => "application/octet-stream",
    ".hlp" => "application/winhlp",
    ".hpp" => "text/plain",
    ".hqx" => "application/mac-binhex40",
    ".hta" => "application/hta",
    ".htc" => "text/x-component",
    ".htm" => "text/html",
    ".html" => "text/html",
    ".htt" => "text/webviewhtml",
    ".hxa" => "application/xml",
    ".hxc" => "application/xml",
    ".hxd" => "application/octet-stream",
    ".hxe" => "application/xml",
    ".hxf" => "application/xml",
    ".hxh" => "application/octet-stream",
    ".hxi" => "application/octet-stream",
    ".hxk" => "application/xml",
    ".hxq" => "application/octet-stream",
    ".hxr" => "application/octet-stream",
    ".hxs" => "application/octet-stream",
    ".hxt" => "text/html",
    ".hxv" => "application/xml",
    ".hxw" => "application/octet-stream",
    ".hxx" => "text/plain",
    ".i" => "text/plain",
    ".ico" => "image/x-icon",
    ".ics" => "application/octet-stream",
    ".idl" => "text/plain",
    ".ief" => "image/ief",
    ".iii" => "application/x-iphone",
    ".inc" => "text/plain",
    ".inf" => "application/octet-stream",
    ".inl" => "text/plain",
    ".ins" => "application/x-internet-signup",
    ".ipa" => "application/x-itunes-ipa",
    ".ipg" => "application/x-itunes-ipg",
    ".ipproj" => "text/plain",
    ".ipsw" => "application/x-itunes-ipsw",
    ".iqy" => "text/x-ms-iqy",
    ".isp" => "application/x-internet-signup",
    ".ite" => "application/x-itunes-ite",
    ".itlp" => "application/x-itunes-itlp",
    ".itms" => "application/x-itunes-itms",
    ".itpc" => "application/x-itunes-itpc",
    ".IVF" => "video/x-ivf",
    ".jar" => "application/java-archive",
    ".java" => "application/octet-stream",
    ".jck" => "application/liquidmotion",
    ".jcz" => "application/liquidmotion",
    ".jfif" => "image/pjpeg",
    ".jnlp" => "application/x-java-jnlp-file",
    ".jpb" => "application/octet-stream",
    ".jpe" => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".jpg" => "image/jpeg",
    ".js" => "application/x-javascript",
    ".jsx" => "text/jscript",
    ".jsxbin" => "text/plain",
    ".latex" => "application/x-latex",
    ".library-ms" => "application/windows-library+xml",
    ".lit" => "application/x-ms-reader",
    ".loadtest" => "application/xml",
    ".lpk" => "application/octet-stream",
    ".lsf" => "video/x-la-asf",
    ".lst" => "text/plain",
    ".lsx" => "video/x-la-asf",
    ".lzh" => "application/octet-stream",
    ".m13" => "application/x-msmediaview",
    ".m14" => "application/x-msmediaview",
    ".m1v" => "video/mpeg",
    ".m2t" => "video/vnd.dlna.mpeg-tts",
    ".m2ts" => "video/vnd.dlna.mpeg-tts",
    ".m2v" => "video/mpeg",
    ".m3u" => "audio/x-mpegurl",
    ".m3u8" => "audio/x-mpegurl",
    ".m4a" => "audio/m4a",
    ".m4b" => "audio/m4b",
    ".m4p" => "audio/m4p",
    ".m4r" => "audio/x-m4r",
    ".m4v" => "video/x-m4v",
    ".mac" => "image/x-macpaint",
    ".mak" => "text/plain",
    ".man" => "application/x-troff-man",
    ".manifest" => "application/x-ms-manifest",
    ".map" => "text/plain",
    ".master" => "application/xml",
    ".mda" => "application/msaccess",
    ".mdb" => "application/x-msaccess",
    ".mde" => "application/msaccess",
    ".mdp" => "application/octet-stream",
    ".me" => "application/x-troff-me",
    ".mfp" => "application/x-shockwave-flash",
    ".mht" => "message/rfc822",
    ".mhtml" => "message/rfc822",
    ".mid" => "audio/mid",
    ".midi" => "audio/mid",
    ".mix" => "application/octet-stream",
    ".mk" => "text/plain",
    ".mmf" => "application/x-smaf",
    ".mno" => "text/xml",
    ".mny" => "application/x-msmoney",
    ".mod" => "video/mpeg",
    ".mov" => "video/quicktime",
    ".movie" => "video/x-sgi-movie",
    ".mp2" => "video/mpeg",
    ".mp2v" => "video/mpeg",
    ".mp3" => "audio/mpeg",
    ".mp4" => "video/mp4",
    ".mp4v" => "video/mp4",
    ".mpa" => "video/mpeg",
    ".mpe" => "video/mpeg",
    ".mpeg" => "video/mpeg",
    ".mpf" => "application/vnd.ms-mediapackage",
    ".mpg" => "video/mpeg",
    ".mpp" => "application/vnd.ms-project",
    ".mpv2" => "video/mpeg",
    ".mqv" => "video/quicktime",
    ".ms" => "application/x-troff-ms",
    ".msi" => "application/octet-stream",
    ".mso" => "application/octet-stream",
    ".mts" => "video/vnd.dlna.mpeg-tts",
    ".mtx" => "application/xml",
    ".mvb" => "application/x-msmediaview",
    ".mvc" => "application/x-miva-compiled",
    ".mxp" => "application/x-mmxp",
    ".nc" => "application/x-netcdf",
    ".nsc" => "video/x-ms-asf",
    ".nws" => "message/rfc822",
    ".ocx" => "application/octet-stream",
    ".oda" => "application/oda",
    ".odc" => "text/x-ms-odc",
    ".odh" => "text/plain",
    ".odl" => "text/plain",
    ".odp" => "application/vnd.oasis.opendocument.presentation",
    ".ods" => "application/oleobject",
    ".odt" => "application/vnd.oasis.opendocument.text",
    ".one" => "application/onenote",
    ".onea" => "application/onenote",
    ".onepkg" => "application/onenote",
    ".onetmp" => "application/onenote",
    ".onetoc" => "application/onenote",
    ".onetoc2" => "application/onenote",
    ".orderedtest" => "application/xml",
    ".osdx" => "application/opensearchdescription+xml",
    ".p10" => "application/pkcs10",
    ".p12" => "application/x-pkcs12",
    ".p7b" => "application/x-pkcs7-certificates",
    ".p7c" => "application/pkcs7-mime",
    ".p7m" => "application/pkcs7-mime",
    ".p7r" => "application/x-pkcs7-certreqresp",
    ".p7s" => "application/pkcs7-signature",
    ".pbm" => "image/x-portable-bitmap",
    ".pcast" => "application/x-podcast",
    ".pct" => "image/pict",
    ".pcx" => "application/octet-stream",
    ".pcz" => "application/octet-stream",
    ".pdf" => "application/pdf",
    ".pfb" => "application/octet-stream",
    ".pfm" => "application/octet-stream",
    ".pfx" => "application/x-pkcs12",
    ".pgm" => "image/x-portable-graymap",
    ".pic" => "image/pict",
    ".pict" => "image/pict",
    ".pkgdef" => "text/plain",
    ".pkgundef" => "text/plain",
    ".pko" => "application/vnd.ms-pki.pko",
    ".pls" => "audio/scpls",
    ".pma" => "application/x-perfmon",
    ".pmc" => "application/x-perfmon",
    ".pml" => "application/x-perfmon",
    ".pmr" => "application/x-perfmon",
    ".pmw" => "application/x-perfmon",
    ".png" => "image/png",
    ".pnm" => "image/x-portable-anymap",
    ".pnt" => "image/x-macpaint",
    ".pntg" => "image/x-macpaint",
    ".pnz" => "image/png",
    ".pot" => "application/vnd.ms-powerpoint",
    ".potm" => "application/vnd.ms-powerpoint.template.macroEnabled.12",
    ".potx" => "application/vnd.openxmlformats-officedocument.presentationml.template",
    ".ppa" => "application/vnd.ms-powerpoint",
    ".ppam" => "application/vnd.ms-powerpoint.addin.macroEnabled.12",
    ".ppm" => "image/x-portable-pixmap",
    ".pps" => "application/vnd.ms-powerpoint",
    ".ppsm" => "application/vnd.ms-powerpoint.slideshow.macroEnabled.12",
    ".ppsx" => "application/vnd.openxmlformats-officedocument.presentationml.slideshow",
    ".ppt" => "application/vnd.ms-powerpoint",
    ".pptm" => "application/vnd.ms-powerpoint.presentation.macroEnabled.12",
    ".pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    ".prf" => "application/pics-rules",
    ".prm" => "application/octet-stream",
    ".prx" => "application/octet-stream",
    ".ps" => "application/postscript",
    ".psc1" => "application/PowerShell",
    ".psd" => "application/octet-stream",
    ".psess" => "application/xml",
    ".psm" => "application/octet-stream",
    ".psp" => "application/octet-stream",
    ".pub" => "application/x-mspublisher",
    ".pwz" => "application/vnd.ms-powerpoint",
    ".qht" => "text/x-html-insertion",
    ".qhtm" => "text/x-html-insertion",
    ".qt" => "video/quicktime",
    ".qti" => "image/x-quicktime",
    ".qtif" => "image/x-quicktime",
    ".qtl" => "application/x-quicktimeplayer",
    ".qxd" => "application/octet-stream",
    ".ra" => "audio/x-pn-realaudio",
    ".ram" => "audio/x-pn-realaudio",
    ".rar" => "application/octet-stream",
    ".ras" => "image/x-cmu-raster",
    ".rat" => "application/rat-file",
    ".rc" => "text/plain",
    ".rc2" => "text/plain",
    ".rct" => "text/plain",
    ".rdlc" => "application/xml",
    ".resx" => "application/xml",
    ".rf" => "image/vnd.rn-realflash",
    ".rgb" => "image/x-rgb",
    ".rgs" => "text/plain",
    ".rm" => "application/vnd.rn-realmedia",
    ".rmi" => "audio/mid",
    ".rmp" => "application/vnd.rn-rn_music_package",
    ".roff" => "application/x-troff",
    ".rpm" => "audio/x-pn-realaudio-plugin",
    ".rqy" => "text/x-ms-rqy",
    ".rtf" => "application/rtf",
    ".rtx" => "text/richtext",
    ".ruleset" => "application/xml",
    ".s" => "text/plain",
    ".safariextz" => "application/x-safari-safariextz",
    ".scd" => "application/x-msschedule",
    ".sct" => "text/scriptlet",
    ".sd2" => "audio/x-sd2",
    ".sdp" => "application/sdp",
    ".sea" => "application/octet-stream",
    ".searchConnector-ms" => "application/windows-search-connector+xml",
    ".setpay" => "application/set-payment-initiation",
    ".setreg" => "application/set-registration-initiation",
    ".settings" => "application/xml",
    ".sgimb" => "application/x-sgimb",
    ".sgml" => "text/sgml",
    ".sh" => "application/x-sh",
    ".shar" => "application/x-shar",
    ".shtml" => "text/html",
    ".sit" => "application/x-stuffit",
    ".sitemap" => "application/xml",
    ".skin" => "application/xml",
    ".sldm" => "application/vnd.ms-powerpoint.slide.macroEnabled.12",
    ".sldx" => "application/vnd.openxmlformats-officedocument.presentationml.slide",
    ".slk" => "application/vnd.ms-excel",
    ".sln" => "text/plain",
    ".slupkg-ms" => "application/x-ms-license",
    ".smd" => "audio/x-smd",
    ".smi" => "application/octet-stream",
    ".smx" => "audio/x-smd",
    ".smz" => "audio/x-smd",
    ".snd" => "audio/basic",
    ".snippet" => "application/xml",
    ".snp" => "application/octet-stream",
    ".sol" => "text/plain",
    ".sor" => "text/plain",
    ".spc" => "application/x-pkcs7-certificates",
    ".spl" => "application/futuresplash",
    ".src" => "application/x-wais-source",
    ".srf" => "text/plain",
    ".SSISDeploymentManifest" => "text/xml",
    ".ssm" => "application/streamingmedia",
    ".sst" => "application/vnd.ms-pki.certstore",
    ".stl" => "application/vnd.ms-pki.stl",
    ".sv4cpio" => "application/x-sv4cpio",
    ".sv4crc" => "application/x-sv4crc",
    ".svc" => "application/xml",
    ".swf" => "application/x-shockwave-flash",
    ".t" => "application/x-troff",
    ".tar" => "application/x-tar",
    ".tcl" => "application/x-tcl",
    ".testrunconfig" => "application/xml",
    ".testsettings" => "application/xml",
    ".tex" => "application/x-tex",
    ".texi" => "application/x-texinfo",
    ".texinfo" => "application/x-texinfo",
    ".tgz" => "application/x-compressed",
    ".thmx" => "application/vnd.ms-officetheme",
    ".thn" => "application/octet-stream",
    ".tif" => "image/tiff",
    ".tiff" => "image/tiff",
    ".tlh" => "text/plain",
    ".tli" => "text/plain",
    ".toc" => "application/octet-stream",
    ".tr" => "application/x-troff",
    ".trm" => "application/x-msterminal",
    ".trx" => "application/xml",
    ".ts" => "video/vnd.dlna.mpeg-tts",
    ".tsv" => "text/tab-separated-values",
    ".ttf" => "application/octet-stream",
    ".tts" => "video/vnd.dlna.mpeg-tts",
    ".txt" => "text/plain",
    ".u32" => "application/octet-stream",
    ".uls" => "text/iuls",
    ".user" => "text/plain",
    ".ustar" => "application/x-ustar",
    ".vb" => "text/plain",
    ".vbdproj" => "text/plain",
    ".vbk" => "video/mpeg",
    ".vbproj" => "text/plain",
    ".vbs" => "text/vbscript",
    ".vcf" => "text/x-vcard",
    ".vcproj" => "Application/xml",
    ".vcs" => "text/plain",
    ".vcxproj" => "Application/xml",
    ".vddproj" => "text/plain",
    ".vdp" => "text/plain",
    ".vdproj" => "text/plain",
    ".vdx" => "application/vnd.ms-visio.viewer",
    ".vml" => "text/xml",
    ".vscontent" => "application/xml",
    ".vsct" => "text/xml",
    ".vsd" => "application/vnd.visio",
    ".vsi" => "application/ms-vsi",
    ".vsix" => "application/vsix",
    ".vsixlangpack" => "text/xml",
    ".vsixmanifest" => "text/xml",
    ".vsmdi" => "application/xml",
    ".vspscc" => "text/plain",
    ".vss" => "application/vnd.visio",
    ".vsscc" => "text/plain",
    ".vssettings" => "text/xml",
    ".vssscc" => "text/plain",
    ".vst" => "application/vnd.visio",
    ".vstemplate" => "text/xml",
    ".vsto" => "application/x-ms-vsto",
    ".vsw" => "application/vnd.visio",
    ".vsx" => "application/vnd.visio",
    ".vtx" => "application/vnd.visio",
    ".wav" => "audio/wav",
    ".wave" => "audio/wav",
    ".wax" => "audio/x-ms-wax",
    ".wbk" => "application/msword",
    ".wbmp" => "image/vnd.wap.wbmp",
    ".wcm" => "application/vnd.ms-works",
    ".wdb" => "application/vnd.ms-works",
    ".wdp" => "image/vnd.ms-photo",
    ".webarchive" => "application/x-safari-webarchive",
    ".webtest" => "application/xml",
    ".wiq" => "application/xml",
    ".wiz" => "application/msword",
    ".wks" => "application/vnd.ms-works",
    ".WLMP" => "application/wlmoviemaker",
    ".wlpginstall" => "application/x-wlpg-detect",
    ".wlpginstall3" => "application/x-wlpg3-detect",
    ".wm" => "video/x-ms-wm",
    ".wma" => "audio/x-ms-wma",
    ".wmd" => "application/x-ms-wmd",
    ".wmf" => "application/x-msmetafile",
    ".wml" => "text/vnd.wap.wml",
    ".wmlc" => "application/vnd.wap.wmlc",
    ".wmls" => "text/vnd.wap.wmlscript",
    ".wmlsc" => "application/vnd.wap.wmlscriptc",
    ".wmp" => "video/x-ms-wmp",
    ".wmv" => "video/x-ms-wmv",
    ".wmx" => "video/x-ms-wmx",
    ".wmz" => "application/x-ms-wmz",
    ".wpl" => "application/vnd.ms-wpl",
    ".wps" => "application/vnd.ms-works",
    ".wri" => "application/x-mswrite",
    ".wrl" => "x-world/x-vrml",
    ".wrz" => "x-world/x-vrml",
    ".wsc" => "text/scriptlet",
    ".wsdl" => "text/xml",
    ".wvx" => "video/x-ms-wvx",
    ".x" => "application/directx",
    ".xaf" => "x-world/x-vrml",
    ".xaml" => "application/xaml+xml",
    ".xap" => "application/x-silverlight-app",
    ".xbap" => "application/x-ms-xbap",
    ".xbm" => "image/x-xbitmap",
    ".xdr" => "text/plain",
    ".xht" => "application/xhtml+xml",
    ".xhtml" => "application/xhtml+xml",
    ".xla" => "application/vnd.ms-excel",
    ".xlam" => "application/vnd.ms-excel.addin.macroEnabled.12",
    ".xlc" => "application/vnd.ms-excel",
    ".xld" => "application/vnd.ms-excel",
    ".xlk" => "application/vnd.ms-excel",
    ".xll" => "application/vnd.ms-excel",
    ".xlm" => "application/vnd.ms-excel",
    ".xls" => "application/vnd.ms-excel",
    ".xlsb" => "application/vnd.ms-excel.sheet.binary.macroEnabled.12",
    ".xlsm" => "application/vnd.ms-excel.sheet.macroEnabled.12",
    ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    ".xlt" => "application/vnd.ms-excel",
    ".xltm" => "application/vnd.ms-excel.template.macroEnabled.12",
    ".xltx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.template",
    ".xlw" => "application/vnd.ms-excel",
    ".xml" => "text/xml",
    ".xmta" => "application/xml",
    ".xof" => "x-world/x-vrml",
    ".XOML" => "text/plain",
    ".xpm" => "image/x-xpixmap",
    ".xps" => "application/vnd.ms-xpsdocument",
    ".xrm-ms" => "text/xml",
    ".xsc" => "application/xml",
    ".xsd" => "text/xml",
    ".xsf" => "text/xml",
    ".xsl" => "text/xml",
    ".xslt" => "text/xml",
    ".xsn" => "application/octet-stream",
    ".xss" => "application/xml",
    ".xtp" => "application/octet-stream",
    ".xwd" => "image/x-xwindowdump",
    ".z" => "application/x-compress",
    ".zip" => "application/x-zip-compressed"}

	return get_mime[File.extname(filename)]

end

#
# File conversion
# 

IMAGEMAGICK_PATH="D:\\Program Files\\ImageMagick-7.0.2-Q16\\"

def call_ImageMagick_raw command_args
	command = "\"#{IMAGEMAGICK_PATH}\\magick.exe\" #{command_args}" 
	
	puts command+"\n"
	
	system command
end

def image_convert source_filename, target_filename

	print "Converting  \"#{source_filename}\" to \"#{target_filename}\"  \n\n"

	# Let image magick figure out the conversion by looking at the extensions

	command = "\"#{IMAGEMAGICK_PATH}\\magick.exe\" \"#{source_filename}\" \"#{target_filename}\""
	
	system command
	
end

def image_crop source_filename, target_filename, startx, starty, endx, endy

	print "Converting  \"#{source_filename}\" to \"#{target_filename}\"  \n\n"

	# Let image magick figure out the conversion by looking at the extensions
	
	height = endy.to_i - starty.to_i
	witdh = endx.to_i - startx.to_i
	

	command = "\"#{IMAGEMAGICK_PATH}\\magick.exe\" \"#{source_filename}\" -crop #{witdh}x#{height}+#{startx}+#{starty} \"#{target_filename}\""
	
	puts command+"\n"
	
	system command

end

def image_add_text source_filename, target_filename, text

	print "Converting  \"#{source_filename}\" to \"#{target_filename}\"  \n\n"

	# Let image magick figure out the conversion by looking at the extensions

	#call_ImageMagick_raw " \"#{source_filename}\" -undercolor #00000080 -font Candice -pointsize 72 -fill Navy -gravity east  -size 320x -stroke #000C -strokewidth 2 -annotate 0 caption:\"#{text}\" -stroke  none -fill white  -annotate 0 \"#{text}\" \"#{target_filename}\""
	
	font_size = "62" 
	#caption_box_size = "1020x1640"
	caption_box_size = "800x1400"
	gravity = "west"
	
	call_ImageMagick_raw " \"#{source_filename}\" ( -background none -undercolor #00000080  -fill white  -font Corsiva -pointsize #{font_size} -gravity #{gravity} -size #{caption_box_size} caption:\"#{text}\" ) -compose over -composite \"#{target_filename}\""


end


#
# OCR
#
OCR_TESSERACT_PATH="D:\\Program Files\\tesseract\\"

def call_Tessearct_raw command_args
	command = "\"#{OCR_TESSERACT_PATH}tesseract.exe\" #{command_args}" 
	
	puts command+"\n"
	
	system command
end

def OCR_extract_txt_from_png source_file

	puts "Extracting TXT files from #{source_file} ... \n\n"
	
	language="por"
	#language="eng"
	
	target_file = source_file + ".ocr.txt"
	  
	call_Tessearct_raw "\"#{source_file}\" \"#{target_file}\" -psm 3 --tessdata-dir \"#{OCR_TESSERACT_PATH}tessdata\" -l #{language} \"#{OCR_TESSERACT_PATH}tessdata\\pdf.config"
	  
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

def copy_and_rename_file_to_target_dir file, new_name, target_dir
	print "Copying and renaming file: #{file} to \"#{target_dir}\"\\#{new_name}  \n\n"
	system "xcopy \"#{file}\" \"#{target_dir}\"\\#{new_name}"
end

def delete_file target_archive
	puts "Deleting \"#{target_archive}\"\n"
	
	system "del \"#{target_archive}\" /Q"
end

def dump_file_from_string target_filename, string

	print "Writing file: #{target_filename}\"  ...\n\n"

	File.open(target_filename, 'w') { 
			|file| file.write(string)
	}
	
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

	#system "del #{target_archive} /Q"
	
	delete_file target_archive

	# Workaround for EPUB as described in https://sourceforge.net/p/sevenzip/feature-requests/1212/
	
	system "ren \".\\#{source_dir}\\mimetype\" !mimetype"
	
	system "#{SEVENZIP_PATH} a \"#{target_archive}\" -mx0 -r -y \".\\#{source_dir}\\mimetype\""
	
	result = system "#{SEVENZIP_PATH} a \"#{target_archive}\" -mx0 -r -y \".\\#{source_dir}\\*\" -x!\".\\#{source_dir}\\mimetype\""

	system "#{SEVENZIP_PATH} rn \"#{target_archive}\" !mimetype mimetype"
	
	system "ren \".\\#{source_dir}\\!mimetype\" mimetype"
	
	return result
end


#
# Video utils
#
FFMPEG_DEFAULT_PATH="D:\\Program Files\\ffmpeg-20180102\\bin\\"
FFMPEG_DEFAULT_HDACCEL="-hwaccel dxva2 -threads 1"

def call_ffmpeg_raw cmd_options, preview
   conv_command = "\"#{FFMPEG_DEFAULT_PATH}ffmpeg.exe\"  #{cmd_options} "

   puts "#{conv_command}\n"
   puts "Running FFMPEG conversion...\n"
   
   if (!preview)
	system "#{conv_command}\n"
   end
end

def video_extract_jpg_thumbnails tmp_vob_filename, options

   system "mkdir #{tmp_vob_filename}.images"
   
   if options.scale.nil?
	options.scale = "720:576"
   end

  if options.fps.nil?
	options.fps = "1/60"
   end
  
  if options.subtitles.nil?
	subtiles = ""
  else
    subtitles = "subtitles=#{options.subtitles},"
  end
    
  
 
   call_ffmpeg_raw  "#{FFMPEG_DEFAULT_HDACCEL} -i \"#{tmp_vob_filename}\"  -vf \"#{subtitles}scale=#{options.scale},yadif,fps=#{options.fps}\" \"#{tmp_vob_filename}.images\\img%03d.png\" ", false
   
end