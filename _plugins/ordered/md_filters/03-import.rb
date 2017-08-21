$myfilter = lambda{|content|
	newcontent = ""
	srcline = 0
	if !content.match(/@importmd|@importlisting/)
		return content
	end

	content.each_line{|txt|
		srcline += 1
		if mtc = txt.match(/@importmd\((.+)\)/)
			File.open(mtc[1]){|f|
				newcontent += import f.read
			}

			unless newcontent.match(/\n$/)
				newcontent +=  "\n"
			end
		elsif mtc = txt.match(/@importlisting(\[[^\]]+\])?\((.+?)\s+([a-zA-Z0-9]+)?\)/)
			caption, file, type = mtc[1], mtc[2], mtc[3]

			if caption
				newcontent += "```#{type}:#{caption.match(/\[(.*)\]/)[1]}\n"
			else
				newcontent += "```#{type}\n"
			end

			File.open(file){|txts|
				txts.each_line{|ln|
					newcontent += ln
				}
			}

			newcontent +=
				unless newcontent.match(/\n$/)
					"\n```\n"
				else
					"```\n"
				end
		else
			newcontent += txt
		end
	}

	newcontent
}
