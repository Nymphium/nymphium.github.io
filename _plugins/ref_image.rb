module Jekyll
  class RefImage < Liquid::Tag
    def initialize(name, filename_alternative, tokens)
      super

      sp = nil

      if filename_alternative.match(/^\s*"/)
	sp = filename_alternative.match(/^\s*"([^"]+)"\s*(.*?)\s*$/)
      else
	sp = filename_alternative.match(/^\s*(\S+)\s+(.*?)\s*$/)
      end

      @filename = sp[1]
      @alternative = sp[2]
    end

    def render(context)
      @filename
    end
  end
end
