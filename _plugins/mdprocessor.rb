# This processor DO NOTHING; _plugins/ordered/md_filters/99-redcarpet.rb does

class Jekyll::Converters::Markdown::MyCustomProcessor
  def initialize(config)
    @config = config
  end

  def convert(content)
    content
  end
end
