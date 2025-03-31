# https://github.com/takuti/jekyll-lazy-tweet-embedding
require 'open-uri'
require 'json'

# convert tweet url to embedding html
lambda { |content|
  embedded_content = content
  content.scan(%r{(https?://(twitter|x)\.com/[a-zA-Z0-9_]+/status/([0-9]+)/?)}).each do |url, _, id|
    tweet_html = nil

    if File.exist? "twicache/#{id}"
      File.open("twicache/#{id}", 'r') { |f| tweet_html = f.read }
    else
      tweet_json = URI.open("https://api.twitter.com/1/statuses/oembed.json?id=#{id}").read
      tweet_html = JSON.parse(tweet_json, { symbolize_names: true })[:html]
      Dir.mkdir('twicache') unless File.exist?('twicache')
      File.open("twicache/#{id}", 'w+') { |f| f.write(tweet_html) }
    end

    embedded_content = embedded_content.gsub(/#{url}/,
                                             "<div class=\"enclosed-tweet\" align=\"center\">#{tweet_html}</div>")
  rescue OpenURI::HTTPError
    embedded_content = embedded_content.gsub(/#{url}/,
                                             "<span class=\"twitter-not-found\">this tweet not found: #{url}</span>")
  end

  embedded_content
}
