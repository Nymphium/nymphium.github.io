lambda {|content|
	if content.match(/ORD-FNS/)
		content.sub(/ORD-FNS/, '<div class="ord-fns" style="display: none">')
			.sub(/END-OF-ORD-FNS/, '</div>')
	else
		content
	end
}
