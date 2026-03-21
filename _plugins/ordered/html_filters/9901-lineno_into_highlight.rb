require 'nokogiri'

lambda { |content|
  html = Nokogiri::HTML(content)

  html.css('div.lineno-source').each do |lineno_div|
    # Find the next .highlight sibling
    highlight = lineno_div.next_element
    highlight = highlight.next_element while highlight && !highlight.matches?('div.highlight')
    next unless highlight

    highlight['class'] = "#{highlight['class']} has-lineno"

    lineno_div.remove

    # Create lineno pre with each number wrapped in a span
    lineno_pre = Nokogiri::XML::Node.new('pre', html)
    lineno_pre['class'] = 'lineno'

    lineno_div.content.strip.split("\n").each do |num|
      span = Nokogiri::XML::Node.new('span', html)
      span['class'] = 'lineno-line'
      span['data-line'] = num.strip
      span.content = num.strip
      lineno_pre.add_child(span)
    end

    code_pre = highlight.at_css('pre')
    next unless code_pre

    code_body = Nokogiri::XML::Node.new('div', html)
    code_body['class'] = 'code-body'

    # listing-name stays in highlight, icon stays inline inside listing-name
    listing_name = highlight.at_css('span.listing-name')
    if listing_name
      listing_name.add_next_sibling(code_body)
    elsif highlight.children.empty?
      highlight.add_child(code_body)
    else
      highlight.children.first.add_previous_sibling(code_body)
    end

    code_body.add_child(lineno_pre)
    code_body.add_child(code_pre)
  end

  html.xpath('/html/body/*').to_s
}
