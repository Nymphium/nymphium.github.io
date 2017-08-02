require'nokogiri'
# this is a set of 'html_filters/99-listing_name_into_div.rb'

def listing_name content
	in_listing = false
	acc = ""

	content.each_line{|txt|
		if l = txt.match(/^\s*```\s*([^:]*)\s*:?\s*(.*)$/)
			if not in_listing
				in_listing = true
				acc += "<span class=\"listing-name\">#{l[2]}</span>\n\n```#{l[1]}".chomp + "\n"
			else
				in_listing = false
				acc += "```\n"
			end
		else
			acc += txt
		end
	}

	acc
end

module Jekyll
	module Converters
		class Markdown < Converter
			alias nolisting_name_convert convert

			def convert(content)
				nolisting_name_convert(listing_name content)
			end
		end
	end
end

