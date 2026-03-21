require 'nokogiri'

# Rouge lang name → Devicon directory name (only where they differ)
DEVICON_LANG_ALIAS = {
  'html' => 'html5',
  'shell' => 'bash',
  'shell-session' => 'bash',
  'sh' => 'bash',
  'tex' => 'latex',
  'nix' => 'nixos',
}.freeze

DEVICON_SVG_BASE = 'https://cdn.jsdelivr.net/gh/devicons/devicon@v2.17.0/icons'.freeze

lambda { |content|
  html = Nokogiri::HTML(content)

  html.xpath('//p[span[@class="listing-name"]]').each do |pspan|
    highlight = pspan.next_element
    highlight = highlight.next_element while highlight && !highlight.matches?('div.highlight')
    next unless highlight

    span = pspan.remove.xpath('span').remove
    highlight.children.first.add_previous_sibling(span)

    listing_name = highlight.at_css('span.listing-name')
    next unless listing_name

    code_el = highlight.at_css('code[data-lang]')
    lang = code_el&.[]('data-lang')
    next unless lang

    devicon_name = DEVICON_LANG_ALIAS.fetch(lang, lang)
    icon = Nokogiri::XML::Node.new('img', html)
    icon['class'] = 'listing-icon'
    icon['src'] = "#{DEVICON_SVG_BASE}/#{devicon_name}/#{devicon_name}-original.svg"
    icon['alt'] = lang
    icon['onerror'] = "this.style.display='none'"

    if listing_name.children.empty?
      listing_name.add_child(icon)
    else
      listing_name.children.first.add_previous_sibling(icon)
    end
  end

  html.xpath('//span[@class="listing-name" and string-length(text()) = 0]').remove
  html.xpath('/html/body/*').to_s
}
