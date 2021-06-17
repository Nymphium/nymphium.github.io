require 'nokogiri'

lambda { |content|
  html = Nokogiri::HTML content

  pres = html.xpath('//div[@class="highlight"]/pre[starts-with(@class, "highlight")]')

  pres.each_with_index do |pre, _idx|
    code = pre.xpath('code').first
    lang = pre['class'].match(/^highlight (.*)/)&.[](1)

    next unless lang

    pre.remove_attribute('class')
    code['class'] = "language-#{lang}"
    code['data-lang'] = lang
  end

  html.xpath('/html/body/*').to_s
}
