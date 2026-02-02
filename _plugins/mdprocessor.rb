# frozen_string_literal: true

# This processor DO NOTHING; _plugins/ordered/md_filters/99-redcarpet.rb does

module Jekyll
  module Converters
    class Markdown
      class MyCustomProcessor
        def initialize(config)
          @config = config
        end

        def convert(content)
          content
        end
      end
    end
  end
end
