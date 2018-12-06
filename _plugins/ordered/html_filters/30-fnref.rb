require'nokogiri'

lambda {|content|
	html = Nokogiri::HTML content

	fnrefs = html.xpath('//fnref')

	fnrefs.each_with_index{|fnref, idx|
		sup = fnref.xpath('sup')
		title = sup.attribute('title')
		id = sup.attribute('id')
		a = fnref.xpath('sup').remove.xpath('a')

		a.attribute('title', title)
		a.attribute('id', id)
		html.xpath('//fnref')[idx].add_previous_sibling(a)
	}

	html.xpath('//fnref').remove
	html.xpath('/html/body/*').to_s
}
