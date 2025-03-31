module Jekyll
  module Tags
    class TwID < Liquid::Tag
      def initialize(tag_name, post, tokens)
        super
        @post = post
      end

      def render(_context)
        "[@#{@post}](https://x.com/#{@post})".gsub('_', '\\_')
      end
    end
  end
end

Liquid::Template.register_tag('twid', Jekyll::Tags::TwID)
