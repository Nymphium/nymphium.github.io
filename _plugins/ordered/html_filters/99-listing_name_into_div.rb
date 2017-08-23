require'nokogiri'

lambda {|content|
	html = Nokogiri::HTML content

	pspans = html.xpath('//div[@class="highlight"]/preceding-sibling::p[span[@class="listing-name"]]')
	divs = html.xpath('//p[span[@class="listing-name"]]/following-sibling::div[@class="highlight"]')
	pspans.each_with_index{|pspan, idx|
		span = pspan.remove.xpath('span').remove
		divs[idx].children.first.add_previous_sibling(span)
	}

	html.xpath('//span[@class="listing-name" and string-length(text()) = 0]').remove
	html.xpath('/html/body/*').to_s
}
