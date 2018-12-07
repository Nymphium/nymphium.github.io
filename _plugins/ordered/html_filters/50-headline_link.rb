require'nokogiri'
require'cgi'

lambda {|content|
	html = Nokogiri::HTML content

	1.upto(3){|x|
		hxs = html.xpath("//h#{x}[not(@class)]")
		hxs.each_with_index{|hx, idx|
			orig_inner = hx.inner_html
			id = CGI.escape orig_inner
			hx['id'] = id
			hx.inner_html = "<a class=\"headerlink\" href=\"\##{id}\">#{orig_inner}</a>"
		}
	}

	html.xpath('/html/body/*').to_s
}
