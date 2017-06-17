def import content
	newcontent = ""
	srcline = 0

	content.each_line{|txt|
		srcline += 1
		if mtc = txt.match(/@importmd\((.+)\)/)
			File.open(mtc[1]){|f|
				newcontent += import f.read
			}

			unless newcontent.match(/\n$/)
				newcontent +=  "\n"
			end
		elsif mtc = txt.match(/@importlisting(\[[^\]]+\])?\((.+?)(\s+[a-zA-Z0-9]+)?\)/)
			caption, file, type = mtc[1], mtc[2], mtc[3]

			if caption
				newcontent += "```#{type}:#{caption}\n"
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
end

module Jekyll
	# for markdown, extend oroginal parser's convert method
	module Converters
		class Markdown < Converter
			priority :highest
			alias notimport_convert convert

			def convert(content)
				notimport_convert(import(content))
			end
		end
	end
end
