def sectionize content
	section = content
	has_section = false
	codeflag = false
	secnum, subsecnum, subsubsecnum = 0, 0, 0
	content.each_line{|txt|
		next unless has_section = (txt.match("<!--sectionize on-->") != nil) || has_section
		next if codeflag = (txt.match(/^\s*```(?!`)/) != nil) ^ codeflag

		# section
		if sec = txt.match(/^#\s*([^!#].*)$/)
			section.sub!(/^#\s*#{Regexp.escape sec[1]}/, "##{secnum += 1}. #{sec[1]}")
			subsecnum = 0
			subsubsecnum = 0
		else
			txt.match(/^#\!\s*([^#].*)$/){|nonumsec|
				section.sub!(/^#\!\s*#{Regexp.escape nonumsec[1]}/, "##{nonumsec[1]}")
		} end

		## subsection
		if subsec = txt.match(/^##\s*([^!#].*)$/)
			section.sub!(/^##\s*#{Regexp.escape subsec[1]}/, "###{secnum}-#{subsecnum += 1}. #{subsec[1]}")
			subsubsecnum = 0
		else
			txt.match(/^##\!\s*([^#].*)$/){|nonumsubsec|
				section.sub!(/^##\!\s*#{Regexp.escape nonumsubsec[1]}/, "###{nonumsubsec[1]}")
		} end

		### subsubsection
		if subsec = txt.match(/^###\s*([^!#].*)$/)
			section.sub!(/^###\s*#{Regexp.escape subsec[1]}/, "####{secnum}-#{subsecnum}-#{subsubsecnum += 1}. #{subsec[1]}")
		else
			txt.match(/^###\!\s*([^#].*)$/){|nonumsubsec|
				section.sub!(/^###\!\s*#{Regexp.escape nonumsubsec[1]}/, "####{nonumsubsec[1]}")
		} end
	}
	section
end

module Jekyll
	# for markdown, extend oroginal parser's convert method
	module Converters
		class Markdown < Converter
			alias notsectionize_convert convert

			def convert(content)
				notsectionize_convert(sectionize(content))
			end
		end
	end

	# for html, extend converter as a plugin
	class SectionizeIntoHTML < Converter
		safe true
		priority :low

		def matches(ext)
			ext =~ /^\.html$/i
		end

		def output_ext(ext)
			".html"
		end

		def convert(content)
			sectionize(content)
		end
	end
end
