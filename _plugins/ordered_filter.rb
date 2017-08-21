$MD_FILTERS = []
$HTML_FILTERS = []

def ordered_filter filters, content
	converted = content

	filters.map{|filter|
		converted = filter[converted]
	}

	converted
end

def init_filters path
	Dir[File.expand_path("../ordered/#{path}/", __FILE__) << '/*.rb'].sort.map{|file|
		File.open(file){|f|
			eval f.read
		}
	}
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
