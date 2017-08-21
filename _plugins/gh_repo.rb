module Jekyll
  class GHRepo < Liquid::Tag

	def initialize(name, repository, tokens)
	  super
	  @repository = repository.strip

	end

	def render(context)
		@repository
	  # "<div class=\"github-widget\" data-repo=\"#{@repository}\"></div>"
	end
  end
end

Liquid::Template.register_tag('gh_repo', Jekyll::GHRepo)

