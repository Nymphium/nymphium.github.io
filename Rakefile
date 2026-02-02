# frozen_string_literal: true

require 'rake'
require 'time'

BUNDLE = !ENV['BUNDLE'].to_s.empty? ? ENV['BUNDLE'] : 'bundle'

# Usage: rake preview
desc 'Launch preview environment'
task :preview do
  skip_net = ENV['SKIP_NET'] || 'true'
  env = { 'SKIP_NET' => skip_net, 'JEKYLL_ENV' => 'development' }
  cmd = [BUNDLE, 'exec', 'jekyll', 'serve', '-w', '--drafts', '--incremental']
  cmd += ['--host', ENV['host']] if ENV['host']

  sh(env, *cmd)
end

# Usage: rake build
desc 'Build the site locally'
task :build do
  sh({ 'JEKYLL_ENV' => 'development' }, BUNDLE, 'exec', 'jekyll', 'build')
end

# Usage: rake clean
desc 'Clean generated site and cache'
task :clean do
  sh(BUNDLE, 'exec', 'jekyll', 'clean')
end
