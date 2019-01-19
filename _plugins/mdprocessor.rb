class Jekyll::Converters::Markdown::MyCustomProcessor
  def initialize(config)
    require 'redcarpet'
    @config = config
  rescue LoadError
    STDERR.puts 'You are missing a library required for Markdown. Please run:'
    STDERR.puts '  $ [sudo] gem install funky_markdown'
    raise FatalException.new("Missing dependency: funky_markdown")
  end

  def convert(content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :no_intra_emphasis => true, :footnotes => true)
    markdown.render(content)
  end
end
