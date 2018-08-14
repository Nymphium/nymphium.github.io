lambda{|content|
	mcom = (/<!--+\s*orderedfn\s*--+>/)
	in_code = false
	fns = []

	if !content.match mcom
		return content
	end

	newcontent = ""
	header = ""

	content.each_line{|line|
		if line.match mcom
			header = newcontent
			newcontent = ""
			next
		end

		if in_code then
			if line.match?(/^```$/)
				in_code = false
			end

			newcontent += line
			next
		end

		if (in_code = line.match?(/^````/))
			next
		end

		if c = line.match(/^(\[\^[^\]]+\]):/)
			fns.push c[1]
		end

		newcontent += line
	}

	ord_fns = <<-SP
ORD-FNS
#{fns.reduce{|z, fn| z + "\n" + fn}}
END-OF-ORD-FNS
	SP

	header + ord_fns + newcontent
}
