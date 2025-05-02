# frozen_string_literal: true

require 'rake'
require 'time'

BUNDLE = ENV['BUNDLE']&.length&.> 0 ? ENV['BUNDLE'] : 'bundle'

# ソースブランチでビルドを実施し、成果物を一時ディレクトリに退避
def build_on_source_branch(temp_dir)
  puts '# Source branch でビルド開始'
  sh('_bin/twicardpic_update')
  sh("JEKYLL_ENV=production #{BUNDLE} exec jekyll build")
  
  # 一時ディレクトリの作成と成果物・キャッシュの移動
  sh("mkdir -p #{temp_dir}/dist #{temp_dir}/cache")
  sh("mv _site/* #{temp_dir}/dist")
  sh("mv .jekyll-cache twicache twicard_cache #{temp_dir}/cache")
end

# master ブランチへビルド成果物を展開してコミット
def deploy_to_master(temp_dir, message)
  puts '# Master branch に展開開始'
  sh('git checkout master')
  # .git を除くすべてのファイルを削除して、クリーンな状態にする
  sh('rm -rf $(ls | grep -v .git)')
  # 一時ディレクトリから成果物をコピー
  sh("cp -r #{temp_dir}/dist/* .")
  puts '# Master branch でコミット'
  sh('git add --all')
  sh("git commit -m \"#{message}\" --allow-empty")
end

# Usage: rake deploy
desc 'Begin a push static file to GitHub'
task :deploy do
  temp_dir = "/tmp/nymphiumgithubio-#{Process.pid}"
  message = "deploy at #{Time.now}"
  begin
    # ソースブランチ上でビルド（成果物は一時ディレクトリへ）
    build_on_source_branch(temp_dir)
 
    # ソースブランチでの変更（ソースコードの修正など）をコミット
    puts '# Source branch でコミット'
    sh('git fetch origin')
    sh('git add -A')
    sh("git commit -m \"#{message}\" --allow-empty")

    # master ブランチへ成果物を展開
    deploy_to_master(temp_dir, message)

    sh('git push origin master source')
  rescue StandardError => e
    puts "# ! Deployment failed: #{e.message}"
    exit 1
  ensure
    # デプロイ完了後、ソースブランチに戻りサブモジュール更新などを実施
    sh('git checkout source')
    sh('git submodule update')

    sh("mv #{temp_dir}/cache/* #{temp_dir}/cache/.jekyll-cache .")
    # 一時ディレクトリは必ず削除
    sh("rm -rf #{temp_dir}")
  end
end

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
