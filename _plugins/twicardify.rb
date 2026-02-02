# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'
require 'digest'
require 'json'

module Jekyll
  module Twicardify
    class << self
      def head_extract(head, attr, start_prop)
        ret = []

        head.xpath("meta[starts-with(@#{attr}, \"#{start_prop}\")]").each do |d|
          sort = d.attribute(attr).to_s
          content = d.attribute('content')

          next unless content

          content = content.text

          if (sort = sort.match(/(description|image|title)$/))
            ret.push [sort[0].to_sym, content]
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

          %(#{txt.match(Regexp.new("^.{#{len}}"))[0]}...)
        else
          txt
        end
      end

      def render_twicard(metainfo)
        desc = metainfo[:description]
        title = metainfo[:title]

        <<~HTML
          <div class="twicard">
            <span class="image"><a href="#{metainfo[:url]}" target="_blank" rel="noopener noreferrer"><div><img src=#{metainfo[:image]}></div></a></span>
            <span class="txt">
              <div class="title"><a href="#{metainfo[:url]}" target="_blank" rel="noopener noreferrer">#{title}</a></div>
              <div class="description">#{desc}</div>
            </span>
          </div>
        HTML
      end

      def extract(alt, url)
        fragment = ''
        dir = 'twicard_cache'

        Dir.mkdir(dir) unless Dir.exist? dir

        if (metainfo = url.match(/^([^#]*)(#.*)$/))
          clean_url = metainfo[1]
          fragment = metainfo[2]
        else
          clean_url = url
        end

        cache_file = "#{dir}/#{Digest::MD5.hexdigest(clean_url)}.json"
        metainfo = {}

        begin
          if File.exist? cache_file
            metainfo = JSON.parse(File.read(cache_file), symbolize_names: true)
          elsif ENV['SKIP_NET'] == 'true'
            metainfo = {
              title: 'Page Title (Network Skipped)',
              description: 'Network request skipped by SKIP_NET',
              url: clean_url,
              image: '/pictures/no_image.png'
            }
          else
            html = URI(clean_url).open(allow_redirections: :all, &:read)

            doc = Nokogiri::HTML.parse(html)
            head = doc.xpath('/html/head')

            title = head.xpath('title')&.text

            extracted = head_extract(head, 'property', '')
                        .merge(head_extract(head, 'name', ''))
                        .merge(head_extract(head, 'property', 'og:'))
                        .merge(head_extract(head, 'name', 'og:'))
                        .merge(head_extract(head, 'property', 'twitter:'))
                        .merge(head_extract(head, 'name', 'twitter:'))
                        .merge(head_extract(head, 'property', 'twitter:text:'))
                        .merge(head_extract(head, 'name', 'twitter:text:'))

            metainfo = extracted
            metainfo[:title] ||= title
            metainfo[:description]&.gsub!(/[\n\r]/i, '')

            File.write(cache_file, JSON.generate(metainfo))
          end
        rescue StandardError => e
          puts "Error processing #{clean_url}: #{e}"
          metainfo = {}
        end

        # Post-processing (fallback logic same as original)
        metainfo[:title] = alt if !metainfo[:title].nil? && metainfo[:title].empty?
        metainfo[:title] = (metainfo[:title] || alt) || ''
        metainfo[:url] = "#{clean_url}#{fragment}"
        metainfo[:image] = metainfo[:image] || '/pictures/no_image.png'

        render_twicard metainfo
      end
    end

    module Tags
      class TwiCardify < Liquid::Tag
        def initialize(tag_name, args, tokens)
          super

          if args.strip.start_with?('"')
            sp = args.match(/^\s*"([^"]*)"\s*(.*?)\s*$/)
          else
            sp = args.match(/^\s*(\S+)\s+(.*?)\s*$/)
          end

          @alt = sp[1]
          @post = sp[2]
        end

        def render(_context)
          Jekyll::Twicardify.extract(@alt, @post)
        end
      end
    end
  end
end

Liquid::Template.register_tag('twicard', Jekyll::Twicardify::Tags::TwiCardify)