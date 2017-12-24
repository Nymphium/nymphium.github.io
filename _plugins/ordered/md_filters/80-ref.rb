# foo[label: hoge] (in section x.y.z) --> foo<label id="ref-hoge"/>
# refer to [ref: hoge]  --> refer to <a href="ref-hoge">x.y.z</a>

def vap s, ss, sss
	s.to_s + ((ss == 0 and "") or ("." + ss.to_s) + (sss == 0 and "" or ("." + sss.to_s)))
end

lambda{|content|
	cont = ""
	codeflag = false
	secnum, subsecnum, subsubsecnum = 0, 0, 0

	ref_val = {}

	content.each_line {|txt|
		if codeflag = (txt.match(/^\s*```(?!`)/) != nil) ^ codeflag
			cont += txt
			next
		end

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

		convd = true

		while convd do
			convd = false
			if label = txt.match(/\[label\s*:\s*([a-zA-Z][^\]]*)\s*\]/)
				esc = label[1]
				txt.sub!(/\[label\s*:\s*[a-zA-Z][^\]]*\]/, "<label id=\"#{esc}\"/>")
				ref_val[esc] = vap secnum, subsecnum, subsubsecnum
				convd = true
			end

			if ref = txt.match(/<(?<disp>[^>]+)>\s*\[ref\s*:\s*(?<refl>[a-zA-Z][^\]]*)\s*\]/)
				esc = ref[:refl]
				disp = ref[:disp]
				txt.sub!(/<[^>]+>\s*\[ref\s*:\s*[a-zA-Z][^\]]*\s*\]/, "<a href=\"##{esc}\">#{disp}</a>")
				convd = true
			elsif ref = txt.match(/\[ref\s*:\s*([a-zA-Z][^\]]*)\s*\]/)
				esc = ref[1]
				txt.sub!(/\[ref\s*:\s*[a-zA-Z][^\]]*\s*\]/, "<a href=\"##{esc}\">#{ref_val[esc]}</a>")
				convd = true
			end
		end

		cont += txt
	}

	cont
}
