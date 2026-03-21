lambda { |content|
  newcontent = ""
  startwith = 0
  codeacc = []
  addlineno = false

  content.each_line { |line|
    unless addlineno
      if (match = line.match(/^\s*<!--\s*linenumber(:(?<startline>\d+))?\s*-->/))
        addlineno = true
        startwith = (match['startline'] || 0).to_i
      else
        newcontent += line
      end

      next
    end

    if codeacc.empty?
      if line.match(/^```/)
        codeacc << line
      else
        newcontent += line
      end
    else
      if line.match(/^```\s*$/)
        codeacc << line
        line_count = codeacc.length - 2
        numbers = (1..line_count).map { |i| i + startwith }.join("\n")
        newcontent += "<div class=\"lineno-source\">#{numbers}</div>\n\n"
        newcontent += codeacc.join

        codeacc = []
        addlineno = false
        startwith = 0
      else
        codeacc << line
      end
    end
  }

  newcontent
}
