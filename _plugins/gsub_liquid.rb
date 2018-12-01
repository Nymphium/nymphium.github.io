require'nokogiri'

# for ordered footnotes

module StripOrdFns
  def strip_ordfns(input)

    if input.match(/ord-fns/)
      html = Nokogiri::HTML input
      html.xpath('//*/div[@class="ord-fns"]').remove

      html.xpath('/html/body/*').to_s
    else
      input
    end
  end
end

Liquid::Template.register_filter(StripOrdFns)

