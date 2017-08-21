$MD_FILTERS = []
$HTML_FILTERS = []


def ordered_filter files, content
	converted = content

	files.map{|file|
		load file
		converted = $myfilter[converted]
	}

	converted
end

def init_filters path
	ret = []
	Dir[File.expand_path("../ordered/#{path}/", __FILE__) << '/*.rb'].each{|file|
		ret << file
	}

	ret.sort
end

module Jekyll
	module Converters
		class Markdown < Converter
			alias md_convert convert

			$MD_FILTERS = init_filters "md_filters"
			$HTML_FILTERS = init_filters "html_filters"

			def convert(content)
				ordered_filter $HTML_FILTERS, (md_convert (ordered_filter $MD_FILTERS, content))
			end
		end
	end
end
