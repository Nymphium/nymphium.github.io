module Jekyll
	module Tags
		class TwID < Liquid::Tag
			def initialize(tag_name, post, tokens)
				super
				@post = post
			end

			def render(context)
				"[@#{@post}](https://twitter.com/#{@post})".gsub! "_", "\\_"
			end
		end
	end
end

Liquid::Template.register_tag('twid', Jekyll::Tags::TwID)

