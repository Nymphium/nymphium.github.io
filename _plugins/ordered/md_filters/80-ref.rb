# foo[label: hoge] (in section x.y.z) --> foo<label id="ref-hoge"/>
# refer to [ref: hoge]  --> refer to <a href="ref-hoge">x.y.z</a>
# [fnref n] --> <a href="#fn[n]">[n]</a>

def vap s, num
	sprintf "%d.%d", s, num
end

lambda{|content|
	cont0, cont = "", ""
	codeflag = false
	secnum, num = 0, 0

	ref_val = {}

	# phase 1: look labels
	content.each_line {|txt|
		if codeflag = (txt.match(/^\s*```(?!`)/) != nil) ^ codeflag
			cont0 += txt
			next
		end

		if txt.match(/^#\s*[^!#].*$/)
			secnum += 1
			num = 0
		end

		convd = true

		while convd do
			convd = false
			if label = txt.match(/\[label\s*:\s*([a-zA-Z][^\]]*)\s*\]/)
				esc = label[1]
				txt.sub!(/\[label\s*:\s*[a-zA-Z][^\]]*\]/, "<label id=\"#{esc}\"/>")
				num += 1
				ref_val[esc] = vap secnum, num
				convd = true
			end
		end

		cont0 += txt
	}


	convd = false

	# phase 2: look and replace ref
	cont0.each_line {|txt|
		if codeflag = (txt.match(/^\s*```(?!`)/) != nil) ^ codeflag
			cont += txt
			next
		end

		convd = true

		while convd do
			# [ref: LABEL]
			if ref = txt.match(/<(?<disp>[^>]+)>\s*\[ref\s*:\s*(?<refl>[a-zA-Z][^\]]*)\s*\]/)
				esc = ref[:refl]
				disp = ref[:disp]
				txt.sub!(/<[^>]+>\s*\[ref\s*:\s*[a-zA-Z][^\]]*\s*\]/, "<a href=\"##{esc}\">#{disp}</a>")
			elsif ref = txt.match(/\[ref\s*:\s*([a-zA-Z][^\]]*)\s*\]/)
				esc = ref[1]
				txt.sub!(/\[ref\s*:\s*[a-zA-Z][^\]]*\s*\]/, "<a href=\"##{esc}\">#{ref_val[esc]}</a>")
			# [fnref: n]
			elsif ref = txt.match(/\[fnref\s*:\s+(\d+)\]/)
				nth = ref[1]
				txt.sub!(/\[fnref\s*:\s+(\d+)\]/, "[<a href=\"#fn#{nth}\">#{nth}</a>]")
			else
				convd = false
			end
		end

		cont += txt
	}

	cont
}
