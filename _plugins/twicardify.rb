require'nokogiri'
require'open-uri'
require'open_uri_redirections'

def head_extract head, attr, start_prop
  ret = []

  head.xpath("meta[starts-with(@#{attr}, \"#{start_prop}\")]").each{|d|
    sort = d.attribute(attr).to_s

    if sort_ = sort.match(/description|image|title/)
      ret.push [sort_[0].to_sym,  d.attribute('content').text]
    end
  }

  return Hash[*ret.flatten(1)]
end

def resizing base_size, txt
  if txt.bytesize > base_size*3
    head = txt.match(Regexp.new "^.{#{base_size}}")[0]
    difflen = head.bytesize - base_size*3

    len = base_size
    if difflen > 0
      len -= (difflen / 3)
    end

    txt.match(Regexp.new "^.{#{len}}")[0] + "..."
  else
    txt
  end
end

def render_twicard h
  desc = h[:description]
  title = h[:title]

  <<-HTML
<div class="twicard">
  <span class="image"><a href="#{h[:url]}" target="_blank" rel="noopener noreferrer"><div><img src=#{h[:image]}></div></a></span>
  <span class="txt">
    <div class="title"><a href="#{h[:url]}" target="_blank" rel="noopener noreferrer">#{title}</a></div>
    <div class="description">#{desc}</div>
  </span>
</div>
  HTML
end

def extract alt, url
  hash = ""

  if h = url.match(/^([^#]*)(#.*)$/)
    url = h[1]
    hash = h[2]
  end

  html = open(URI.encode(url), :allow_redirections => :all){|f|
    f.read
  }

  doc = Nokogiri::HTML.parse(html)
  head = doc.xpath('/html/head')

  title = head.xpath('title').text

  h = (head_extract head, "name", "")
    .merge(head_extract head, "property", "og:")
    .merge(head_extract head, "name", "twitter:")
    .merge(head_extract head, "name", "twitter:text:")

  if h.key?(:image) and h.key?(:description) then
    h[:description].gsub!(/[\n\r]/i, '')
    h[:title] = (h[:title] or title)
    h[:url] = "#{url}#{hash}"
    render_twicard h
  else
    <<-HTML
<center>
  <a href="#{url}#{hash}" target="_blank" rel="noopener noreferrer">#{alt}</a>
</center>
    HTML
  end
end

module Jekyll
  module Tags
    class TwiCardify < Liquid::Tag
      def initialize(tag_name, args, tokens)
        super

        sp = nil

        if args.match(/^\s*"/)
          sp = args.match(/^\s*"([^"]+)"\s*(.*?)\s*$/)
        else
          sp = args.match(/^\s*(\S+)\s+(.*?)\s*$/)
        end

        @alt = sp[1]
        @post = sp[2]
      end

      def render(context)
        extract @alt, @post
      end
    end
  end
end

Liquid::Template.register_tag('twicard', Jekyll::Tags::TwiCardify)
