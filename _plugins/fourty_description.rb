# require'nokogiri'
# require'cgi'

# def desc my_html
	# CGI.escapeHTML(Nokogiri::HTML(my_html.strip.gsub(/\R/, "").gsub(/^.*<divclass="post-content"itemprop="articleBody">/, "")).text.slice(1, 34)) + "......"
# end

# Jekyll::Hooks.register :site, :pre_render do |post, cont|
	# cont.site.posts.each{|hoge|
		# description = desc(hoge.content.inspect)
		# hoge.data["description"] = description.strip.gsub(/\R/, "")
	# }
# end

