require'nokogiri'

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

def listing_name_into_div content
	html = Nokogiri::HTML content

	pspans = html.xpath('//div[@class="highlight"]/preceding-sibling::p[span[@class="listing-name"]]')
	divs = html.xpath('//p[span[@class="listing-name"]]/following-sibling::div[@class="highlight"]')
	pspans.each_with_index{|pspan, idx|
		span = pspan.remove.xpath('span').remove
		divs[idx].children.first.add_previous_sibling(span)
	}

	html.xpath('//span[@class="listing-name" and string-length(text()) = 0]').remove
	html.xpath('/html/body/*').to_s
end

module Jekyll
	module Converters
		class Markdown < Converter
			alias plain_convert convert

			def convert(content)
				listing_name_into_div(plain_convert(listing_name content))
			end
		end
	end
end

