# frozen_string_literal: true

require 'rake'
require 'time'

BUNDLE = ENV['BUNDLE']&.length&.> 0 ? ENV['BUNDLE'] : 'bundle'

# Usage: rake preview
desc 'Launch preview environment'
task :preview do
  command = "JEKYLL_ENV=development #{BUNDLE} exec jekyll serve -w --drafts --incremental"
  command += " --host #{ENV['host']}" if ENV['host']

  sh command
end

# Usage: rake build
desc 'Build the site locally'
task :build do
  sh "JEKYLL_ENV=development #{BUNDLE} exec jekyll build"
end

# Usage: rake clean
desc 'Clean generated site and cache'
task :clean do
  sh "#{BUNDLE} exec jekyll clean"
end
