# frozen_string_literal: true

require 'rake'
require 'yaml'
require 'time'
require 'English'

BUNDLE = ENV['BUNDLE']&.length&.> 0 ? ENV['BUNDLE'] : 'bundle'

SOURCE = '.'
CONFIG = {
  'version' => '0.3.0',
  'themes' => File.join(SOURCE, '_includes', 'themes'),
  'layouts' => File.join(SOURCE, '_layouts'),
  'posts' => File.join(SOURCE, '_posts'),
  'post_ext' => 'md',
  'theme_package_version' => '0.1.0'
}.freeze

# Path configuration helper
module JB
  class Path
    SOURCE = '.'
    Paths = {
      layouts: '_layouts',
      themes: '_includes/themes',
      theme_assets: 'assets/themes',
      theme_packages: '_theme_packages',
      posts: '_posts'
    }.freeze

    def self.base
      SOURCE
    end

    # build a path relative to configured path settings.
    def self.build(path, opts = {})
      opts[:root] ||= SOURCE
      path = "#{opts[:root]}/#{Paths[path.to_sym]}/#{opts[:node]}".split('/')
      path.compact!
      File.__send__ :join, path
    end
  end
end

# Usage: rake deploy
desc 'Begin a push static file to GitHub'
task :deploy do
  dir = "/tmp/nymphiumgithubio-#{echo $PID.chomp}"
  puts '# Build...'
  sh '_bin/twicardpic_update'
  sh "JEKYLL_ENV=production #{BUNDLE} exec jekyll build"
  sh "mkdir -p #{dir}/{dist,cache}"
  sh "mv _site/* #{dir}/dist"
  sh "mv .jekyll-cache twicache twicard_cache #{dir}/cache"

  message = "deploy at #{Time.now}"

  puts '# Push to source branch of GitHub'
  sh 'git add -A'
  sh "git commit -m \"#{message}\" --allow-empty"
  sh 'git push origin source:source'
  sh 'rm about/*'

  sh 'git checkout master'
  sh 'rm -rf $(ls | grep -v .git)'
  sh "cp -r #{dir}/dist/* ."
  puts '# Push to master branch of GitHub'
  sh 'git add *'
  begin
    sh "git commit -m \"#{message}\" --allow-empty "
    sh 'git push -f origin master'
  rescue StandardError => _e
    puts '# ! Error - git command abort'
    sh 'git checkout source'
    sh "mv #{dir}/cache/* #{dir}/cache/.jekyll-cache ."
    sh "rm -rf #{dir}"
    exit - 1
  end
  sh 'git checkout source'
  sh 'git submodule update'
  sh "mv #{dir}/cache/* #{dir}/cache/.jekyll-cache ."
  sh "rm -rf #{dir}"
end

# Usage: rake preview
desc 'Launch preview environment'
task :preview do
  command = "JEKYLL_ENV=development #{BUNDLE} exec jekyll serve -w --drafts"
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
