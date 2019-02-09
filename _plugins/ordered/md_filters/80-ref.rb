# foo[label: hoge] (in section x.y.z) --> foo<label id="ref-hoge"/>
# refer to [ref: hoge]  --> refer to <a href="ref-hoge">x.y.z</a>
# [fnref: n] --> [<a href="#fn[n]">n</a>]

lambda{|content|
	if ! content.match(/\[fnref\s*:\s*\d+\]|\[(ref|label)\s*:\s*[^\]\s]+\]/)
		return content
	end

	cont0, cont = "", ""
	codeflag = false
	@secnum, @num = 0, 0

	@isSectionized = !!content.match(/<!--+\s*sectionize on\s*--+>/)

	def secIncr line
		if @isSectionized and line.match(/^#\s*[^!#].*$/)
			@secnum += 1
			@num = 0
		end
	end

	def render
		if @isSectionized
			sprintf "%d.%d", @secnum, @num
		else
			@num.to_s
		end
	end

	ref_val = {}

	# phase 1: look labels
	content.each_line {|txt|
		if codeflag = (txt.match(/^\s*```(?!`)/) != nil) ^ codeflag
			cont0 += txt
			next
		end

		secIncr txt

		convd = true

		while convd do
			convd = false
			if label = txt.match(/\[label\s*:\s*([a-zA-Z][^\]]*)\s*\]/)
				esc = label[1]
				txt.sub!(/\[label\s*:\s*[a-zA-Z][^\]]*\]/, "<label id=\"#{esc}\"/>\n")
				@num += 1
				ref_val[esc] = render
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
			if ref = txt.match(/<(?<disp>[^>]+)>\s*\[ref\s*:\s*(?<refl>[^\]]+)\s*\]/)
				esc = ref[:refl]
				disp = ref[:disp]
				txt.sub!(/<[^>]+>\s*\[ref\s*:\s*[^\]]+\s*\]/, "<a href=\"##{esc}\">#{disp}</a>\n")
			elsif ref = txt.match(/\[ref\s*:\s*([^\]]+)\s*\]/)
				esc = ref[1]
				txt.sub!(/\[ref\s*:\s*[^\]]+\s*\]/, "<a href=\"##{esc}\">#{ref_val[esc]}</a>\n")
			# [fnref: n]
			elsif ref = txt.match(/\[fnref\s*:\s*(\d+)\]/)
				nth = ref[1]
				txt.sub!(/\[fnref\s*:\s*(\d+)\]/, "<span class=\"cite\">[<fnref>[^#{nth}]</fnref>]</span>\n")
			else
				convd = false
			end
		end

		cont += txt
	}

	cont
}
