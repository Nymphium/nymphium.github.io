module Jekyll
	module Tags
		class TweetUrl < Liquid::Tag
			def initialize(tag_name, post, tokens)
				super
				@post = post
			end

			def render(context)
				"<blockquote class=\"twitter-tweet\" lang=\"en\" data-theme=\"dark\"><a href=\"#{@post}\"></a></blockquote><script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>"
			end
		end
	end
end

Liquid::Template.register_tag('tweet_url', Jekyll::Tags::TweetUrl)

