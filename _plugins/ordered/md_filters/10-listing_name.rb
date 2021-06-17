# ```LANGUAGE:CAPTION
# ...
# ```

lambda { |content|
  in_listing = false
  acc = ''

  content.each_line do |txt|
    if l = txt.match(/^\s*```\s*([^:]*)\s*:?\s*(.*)$/)
      if !in_listing
        in_listing = true
        acc += "<span class=\"listing-name\">#{l[2]}</span>\n\n```#{l[1]}".chomp + "\n"
      else
        in_listing = false
        acc += "```\n"
      end
    else
      acc += txt
    end
  end

  acc
}
