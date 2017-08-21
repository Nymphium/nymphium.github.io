lambda{|content|
	newcontent = ""
	content.each_line{|line|
		if repo = line.match(/\{%\s+gh_repo%s+(.*)\s+%\}/)
			newcontent += "<div class=\"github-widget\" data-repo=\"#{repo[1]}\"></div>"
		else
			newcontent += line
		end
	}

	newcontent
}
