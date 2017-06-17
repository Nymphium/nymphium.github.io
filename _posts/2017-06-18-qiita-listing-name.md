---
layout: post
title: Qiitaっぽいlistingのcaption
tags: [雑感, jekyll]
---

こんにちは､びしょ〜じょです｡（後略）

---

Qiitaっぽくlistingにcaptionを差し込むものがJekyllにも欲しくなった｡
とりあえず以下のようなシンタックスを考える｡

```:Markdownのcode block内にMarkdownのcode blockを書く方法がわからん
``\`lang:caption
......
``\`
```

markdown to HTML converterをグニャッと行くのは面倒なので､これをひとまず次のように変換する｡

```
<span class="listing-name">caption</span>

``\`lang
......
``\`
```

これなら簡単にできる｡

```ruby:listing_name1.rb
def listing_name content
	in_listing = false
	acc = ""

	content.each_line{|txt|
		if l = txt.match(/^\s*```\s*([^:]*)\s*:?\s*(.*)$/)
			if not in_listing
				in_listing = true
				acc += "<span class=\"listing-name\">#{l[2]}</span>\n\n```#{l[1]}".chomp + "\n"
			else
				in_listing = false
				acc += "```\n"
			end
		else
			acc += txt
		end
	}

	acc
end

module Jekyll
	module Converters
		class Markdown < Converter
			priority :low
			alias plain_convert convert

			def convert(content)
				plain_convert(listing_name content)
			end
		end
	end
end
```

これにより以下のような感じになる｡

```html:これ
<p><span class="listing-name">caption</span></p>
<div class="highlight">
	<pre>
	......
	</pre>
</div>
```

これで以下のような感じになってほしい｡

```html:これんなってほしい
<div class="highlight">
	<span class="listing-name">caption</span> <!-- 中に入っとる -->
	<pre>
	......
	</pre>
</div>
```

Jekyllではメソッドをいくつかのタイミングでフックすることができる｡

[Plugins#Hooks | Jekyll](https://jekyllrb.com/docs/plugins/#hooks)

が~~~しかし､markdownから生成されたHTMLをさらに操作する方法がよくわからなかった｡
ので筋肉やっていき


```ruby:listing_name.rb
require'nokogiri'

def listing_name content
	......
end

def listing_name_into_div content
	html = Nokogiri::HTML content

	pspans = html.xpath('//div[@class="highlight"]/preceding-sibling::p[span[@class="listing-name"]]')
	divs = html.xpath('//p[span[@class="listing-name"]]/following-sibling::div[@class="highlight"]')
	pspans.each_with_index{|pspan, idx|
		span = pspan.remove.xpath('span').remove
		divs[idx].children.first.add_previous_sibling(span)
	}

	# キャプションが空のときは消す
	html.xpath('//span[@class="listing-name" and string-length(text()) = 0]').remove
	html.xpath('/html/body/*').to_s
end

module Jekyll
	module Converters
		class Markdown < Converter
			# priority :lowest
			# lowerstにするとなんかぶち壊れたのでヤバい､適宜ほかをhigherにしていって
			alias plain_convert convert

			def convert(content)
				# すぐにヤバくなりそう
				listing_name_into_div(plain_convert(listing_name content))
			end
		end
	end
end
```

バイトのおかげでXPathに少し詳しくなりました｡webはやめよう｡

---

『劇場版 魔法科高校の劣等生 星を呼ぶ少女』舞台挨拶LV付きを観に行った｡
何故か徹夜で行ってしまったので爆睡するかと思ったが､大音量に手の混んだ魔法エフェクト､そしていつもと変わらない!! お兄様クオリティーで大変面白かったので終始笑いながら観た｡
どんな敵が出ても最終的に被害0でお兄様大勝利なのでアンパンマン並に安心して観られますね｡

