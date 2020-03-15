# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

def head_extract(head, attr, start_prop)
  ret = []

  head.xpath("meta[starts-with(@#{attr}, \"#{start_prop}\")]").each do |d|
    sort = d.attribute(attr).to_s
    content = d.attribute('content')

    next unless content

    content = content.text

    if sort_ = sort.match(/(description|image|title)$/)
      ret.push [sort_[0].to_sym, content]
    end
  end

  Hash[*ret.flatten(1)]
end

def resizing(base_size, txt)
  if txt.bytesize > base_size * 3
    head = txt.match(Regexp.new("^.{#{base_size}}"))[0]
    difflen = head.bytesize - base_size * 3

    len = base_size
    len -= (difflen / 3) if difflen.positive?

    txt.match(Regexp.new("^.{#{len}}"))[0] + '...'
  else
    txt
  end
end

def render_twicard(h)
  desc = h[:description]
  title = h[:title]

  <<~HTML
    <div class="twicard">
      <span class="image"><a href="#{h[:url]}" target="_blank" rel="noopener noreferrer"><div><img src=#{h[:image]}></div></a></span>
      <span class="txt">
        <div class="title"><a href="#{h[:url]}" target="_blank" rel="noopener noreferrer">#{title}</a></div>
        <div class="description">#{desc}</div>
      </span>
    </div>
  HTML
end

def extract(_alt, url)
  hash = ''
  dir = 'twicard_cache'

  if h = url.match(/^([^#]*)(#.*)$/)
    url = h[1]
    hash = h[2]
  end

  html, title = nil
  h = {}

  path = "#{dir}/#{url.gsub(%r{/}i, '')}"

  begin
    if File.exist? path
      File.open(path, 'r') { |f| html = f.read }
    else
      html = URI.open(Addressable::URI.encode(url), allow_redirections: :all, &:read)
      File.open(path, 'w') { |f| f.write(html) }
      puts File.exist? path
    end

    doc = Nokogiri::HTML.parse(html)
    head = doc.xpath('/html/head')

    title = head.xpath('title')

    title = title.text if title

    h = (head_extract head, 'property', '')
        .merge(head_extract(head, 'name', ''))
        .merge(head_extract(head, 'property', 'og:'))
        .merge(head_extract(head, 'name', 'og:'))
        .merge(head_extract(head, 'property', 'twitter:'))
        .merge(head_extract(head, 'name', 'twitter:'))
        .merge(head_extract(head, 'property', 'twitter:text:'))
        .merge(head_extract(head, 'name', 'twitter:text:'))
  rescue StandardError => e
    puts e
  end

  h[:description]&.gsub!(/[\n\r]/i, '')
  h[:title] = (h[:title] || title) || ''
  h[:url] = "#{url}#{hash}"
  h[:image] = h[:image] || '/picture/no_image.png'
  render_twicard h
end

module Jekyll
  module Tags
    class TwiCardify < Liquid::Tag
      def initialize(tag_name, args, tokens)
        super

        sp = nil

        sp = if args.match(/^\s*"/)
               args.match(/^\s*"([^"]*)"\s*(.*?)\s*$/)
             else
               args.match(/^\s*(\S+)\s+(.*?)\s*$/)
             end

        # pp sp

        # if sp == nil
        # pp args
        # pp tokens
        # return
        # end

        @alt = sp[1]
        @post = sp[2]
      end

      def render(_context)
        extract @alt, @post
      end
    end
  end
end

Liquid::Template.register_tag('twicard', Jekyll::Tags::TwiCardify)
