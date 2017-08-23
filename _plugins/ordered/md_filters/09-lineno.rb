lambda{|content|
	newcontent = ""

	startwith = 0
	codeacc = []
	addlineno = false
	with_caption = false

	content.each_line{|line|
		if !addlineno
			if match = line.match(/^\s*<!--\s*linenumber(:(?<startline>\d+))?\s*-->/)
				addlineno = true
				startwith = (match['startline'] or startwith).to_i
			else
				newcontent += line
			end

			next
		end

		if codeacc.length == 0
			if match = line.match(/^```(?<cap>[^:]*:.*)?/)
				codeacc << line
				with_caption = !!match['cap']
			else
				newcontent += line
			end
		else
			if line.match(/^```/)
				codeacc << line

				newcontent += "<div class=\"codeline#{with_caption ? " with_caption" : ""}\"><pre>" +
					codeacc.take(codeacc.length - 2).map.with_index{|_, i|
						i + 1 + startwith
					}.join("\n") +
					"</pre></div>\n\n" +
					codeacc.join

				codeacc = []
				addlineno = false
			else
				codeacc << line
			end
		end
	}

	newcontent
}
