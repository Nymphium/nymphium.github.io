module Jekyll
	module Converters
		class Markdown < Converter
			alias md_convert convert

			def convert(content)
				converted = md_convert content

				Dir[File.expand_path('../html_filters/', __FILE__) << '/*.rb'].reverse_each{|file|
					load file
					converted = $myfilter[converted]
				}

				converted
			end
		end
	end
end
