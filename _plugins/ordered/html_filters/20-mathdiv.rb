require'nokogiri'

lambda {|content|
	em_to_underscore = lambda{|node|
		node_s = node.to_s
		node_ = Nokogiri::HTML node_s
		node_ = node_.xpath('/html/body/*')

		node_.xpath('//em').each{|em|
			i = em.inner_html
			em.replace("_#{i}_")
		}

		node_
	}

	html = Nokogiri::HTML content

	mathps = html.xpath('//mathp')

	mathps.each_with_index{|mathp, idx|
		c = mathp.inner_html
		mathp.replace(em_to_underscore.call c)
	}
	
	html.to_s
}
