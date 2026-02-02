# frozen_string_literal: true

module Jekyll
  module Converters
    class Markdown < Converter
      # Helper module to load and apply filters
      module OrderedFilter
        class << self
          def apply_filters(filters, content)
            converted = content
            filters.each do |filter|
              converted = filter.call(converted)
            end
            converted
          end

          def init_filters(path)
            Dir[File.expand_path("ordered/#{path}/*.rb", __dir__)].sort.map do |file|
              File.open(file) { |f| eval(f.read) } # rubocop:disable Security/Eval
            end
          end
        end
      end

      # Load filters once
      MD_FILTERS = OrderedFilter.init_filters('md_filters')
      HTML_FILTERS = OrderedFilter.init_filters('html_filters')

      alias md_convert convert

      def convert(content)
        # 1. Apply Markdown Filters
        md_processed = OrderedFilter.apply_filters(MD_FILTERS, content)

        # 2. Convert Markdown to HTML (delegates to original or configured converter)
        html_converted = md_convert(md_processed)

        # 3. Apply HTML Filters
        OrderedFilter.apply_filters(HTML_FILTERS, html_converted)
      end
    end
  end
end
