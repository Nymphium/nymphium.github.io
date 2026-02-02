# frozen_string_literal: true

module Jekyll
  class RefImage < Liquid::Tag
    def initialize(name, filename_alternative, tokens)
      super

      sp = if filename_alternative.match?(/^\s*"/)
             filename_alternative.match(/^\s*"([^"]+)"\s*(.*?)\s*$/)
           else
             filename_alternative.match(/^\s*(\S+)\s+(.*?)\s*$/)
           end

      @filename = sp[1]
      @alternative = sp[2]
    end

    def render(_context)
      @filename
    end
  end
end
