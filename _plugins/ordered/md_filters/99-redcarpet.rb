require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class Rcp
  class HTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  @options = {}
  @extensions = {
    no_intra_emphasis: true,
    footnotes: true,
    tables: true,
    fenced_code_blocks: true,
    smart: true
  }

  @html = HTML.new(@options)
  @markdown = Redcarpet::Markdown.new(@html, @extensions)

  def self.render(content)
    @markdown.render(content)
  end
end

lambda { |content|
  Rcp.render(content)
}
