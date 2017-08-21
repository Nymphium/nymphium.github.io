$myfilter = lambda{|section|
	has_section = false
	codeflag = false
	secnum, subsecnum, subsubsecnum = 0, 0, 0

	section.each_line{|txt|
		next unless has_section = (txt.match(/<!--+\s*sectionize on\s*--+>/) != nil) || has_section
		next if codeflag = (txt.match(/^\s*```(?!`)/) != nil) ^ codeflag

		section.sub!(/<!--+\s*sectionize on\s*--+>/, "")

		# section
		if sec = txt.match(/^#\s*([^!#].*)$/)
			section.sub!(/^#\s*#{Regexp.escape sec[1]}/, "##{secnum += 1}. #{sec[1]}")
			subsecnum = 0
			subsubsecnum = 0
		else
			txt.match(/^#\!\s*([^#].*)$/){|nonumsec|
				section.sub!(/^#\!\s*#{Regexp.escape nonumsec[1]}/, "##{nonumsec[1]}")
			}
		end

		## subsection
		if subsec = txt.match(/^##\s*([^!#].*)$/)
			section.sub!(/^##\s*#{Regexp.escape subsec[1]}/, "###{secnum}-#{subsecnum += 1}. #{subsec[1]}")
			subsubsecnum = 0
		else
			txt.match(/^##\!\s*([^#].*)$/){|nonumsubsec|
				section.sub!(/^##\!\s*#{Regexp.escape nonumsubsec[1]}/, "###{nonumsubsec[1]}")
			}
		end

		### subsubsection
		if subsec = txt.match(/^###\s*([^!#].*)$/)
			section.sub!(/^###\s*#{Regexp.escape subsec[1]}/, "####{secnum}-#{subsecnum}-#{subsubsecnum += 1}. #{subsec[1]}")
		else
			txt.match(/^###\!\s*([^#].*)$/){|nonumsubsec|
				section.sub!(/^###\!\s*#{Regexp.escape nonumsubsec[1]}/, "####{nonumsubsec[1]}")
			}
		end
	}

	section
}
