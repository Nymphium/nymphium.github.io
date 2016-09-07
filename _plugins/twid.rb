module Jekyll
	module Tags
		class TwID < Liquid::Tag
			def initialize(tag_name, post, tokens)
				super
				@post = post
			end

			def render(context)
				rendered = "[@#{@post}](https://twitter.com/#{@post})"

				if rendered.match "_" then
					rendered.gsub! "_", "\\_"
				end

				rendered
			end
		end
	end
end

Liquid::Template.register_tag('twid', Jekyll::Tags::TwID)

