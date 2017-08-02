require'nokogiri'

$myfilter = lambda {|content|
	html = Nokogiri::HTML content
	fnrefs = html.xpath('//sup[starts-with(@id, "fnref")]')

	fnrefs.each{|sup|
		fn = html.xpath("//*[@class='footnotes']//*[@id='#{sup['id'].gsub('ref', '')}']//p")
		nie = Nokogiri::HTML(fn.to_s)
		nie.xpath("//a[@href='##{sup['id']}']").remove
		sup['title'] = nie.xpath('//p').text
	}

	html.xpath('/html/body/*').to_s
}

