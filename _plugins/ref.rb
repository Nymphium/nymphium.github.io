# foo[label: hoge] (in section x.y.z) --> foo<label id="ref-hoge"/>
# refer to [ref: hoge]  --> refer to <a href="ref-hoge">x.y.z</a>

def vap s, ss, sss
	s.to_s + ((ss == 0 and "") or ("." + ss.to_s) + (sss == 0 and "" or ("." + sss.to_s)))
end

def ref_label content
	cont = content
	codeflag = false
	secnum, subsecnum, subsubsecnum = 0, 0, 0

	ref_val = {}

	content.each_line {|txt|
		next if codeflag = (txt.match(/^\s*```(?!`)/) != nil) ^ codeflag

		if txt.match(/^#\s*[^!#].*$/)
			secnum += 1
			subsecnum = 0
			subsubsecnum = 0
		end

		## subsection
		if txt.match(/^##\s*[^!#].*$/)
			subsecnum += 1
			subsubsecnum = 0
		end

		### subsubsection
		if txt.match(/^###\s*[^!#].*$/)
			subsubsecnum += 1
		end

		if label = txt.match(/\[label\s*:\s*([a-zA-Z][a-zA-Z_:]*)\s*\]/)
			esc = Regexp.escape label[1]
			cont.sub!(/\[label\s*:\s*[a-zA-Z][a-zA-Z_:]*\]/, "<label id=\"ref-#{esc}\"/>")
			ref_val[esc] = vap secnum, subsecnum, subsubsecnum
		end

		if ref = txt.match(/\[ref\s*:\s*([a-zA-Z][a-zA-Z_:]*)\s*\]/)
			esc = Regexp.escape ref[1]
			cont.sub!(/\[ref\s*:\s*[a-zA-Z][a-zA-Z_:]*\s*\]/, "<a href=\"#ref-#{esc}\">#{ref_val[esc]}</a>")
		end
	}

	cont
end

module Jekyll
	module Converters
		class Markdown < Converter
			alias notref_label_convert convert

			def convert content
				notref_label_convert ref_label content
			end
		end
	end
end

