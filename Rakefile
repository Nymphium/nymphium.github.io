# frozen_string_literal: true

require 'rake'
require 'time'

# Usage: rake preview
desc 'Launch preview environment'
task :preview do
  skip_net = ENV['SKIP_NET'] || 'false'
  env = { 'SKIP_NET' => skip_net, 'JEKYLL_ENV' => 'development' }
  cmd = [ 'jekyll', 'serve', '-w', '--drafts', '--incremental']
  cmd += ['--host', ENV['host']] if ENV['host']

  sh(env, *cmd)
end

# Usage: rake build
desc 'Build the site locally'
task :build do
  sh({ 'JEKYLL_ENV' => 'development' },  'jekyll', 'build')
end

# Usage: rake clean
desc 'Clean generated site and cache'
task :clean do
  sh( 'jekyll', 'clean')
end
