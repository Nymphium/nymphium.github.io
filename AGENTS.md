# Agent Guide for Blog Development

このプロジェクトは `direnv` と `nix` (Flakes) を使用して開発環境を構築しており、Rubyの依存関係は `bundix` を介して Nix によって管理されています。

## 開発環境の前提
- **direnv**: ディレクトリに入ると自動的に環境変数が読み込まれます。
- **nix**: 依存関係（Ruby、Jekyll、その他ツール）を Nix パッケージとして提供します。
- **bundix**: `Gemfile` から `gemset.nix` を生成し、Nix が Gem を管理できるようにします。
- **ruby-lsp**: Ruby の Language Server です。
- **nil**: Nix の Language Server です。

## 重要: bundle コマンドの制限
- **`bundle install` や `bundle exec` は使用しないでください。**
- 依存関係は Nix 経由で提供されるため、直接 `jekyll` などのコマンドを実行できます。
- Gem のインストールは Nix が行います。

## 依存関係（Gem）の管理ワークフロー
新しい Gem を追加したり更新したりする場合は、以下の手順で行います。

1. **Gemfile の編集**:
   `Gemfile` に必要な Gem を追加または更新します。
2. **Gemfile.lock と gemset.nix の更新**:
   以下のコマンドを実行して、Nix 用の定義ファイルを再生成します。
   ```bash
   nix run .#patched-bundix
   ```
   ※ このコマンドは `Gemfile.lock` も同時に更新します。
3. **環境の再ロード**:
   ```bash
   direnv reload
   ```

## 主要なコマンド
- **プレビュー**: `jekyll serve --drafts` または `rake preview`
- **ビルド**: `jekyll build` または `rake build`
- **デプロイ**: `_bin/emergency_deploy`（必要に応じて）

## エージェントへの指示
- 新しい記事の作成時には `_bin/articlegen` を利用できるか確認してください。
- ファイル変更後は `jekyll build` でビルドが通るか確認してください。
- Ruby 関連のエラーが発生した場合は、`gemset.nix` が最新か、`direnv` が正しく適用されているかを確認してください。

## トラブルシューティング
### 最新の記事が表示されない場合
`rake preview` (`jekyll serve`) は高速化のために `--incremental` オプションを使用しています。これにより、新しい記事を追加した際やインデックスページの更新が反映されない場合があります。
その場合は、以下のコマンドでキャッシュをクリアしてから再実行してください。
```bash
rake clean
rake preview
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
