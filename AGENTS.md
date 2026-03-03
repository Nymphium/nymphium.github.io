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

<!-- BEGIN BEADS INTEGRATION -->
## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Dolt-powered version control with native sync
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**

```bash
bd ready --json
```

**Create new issues:**

```bash
bd create "Issue title" --description="Detailed context" -t bug|feature|task -p 0-4 --json
bd create "Issue title" --description="What this issue is about" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**

```bash
bd update <id> --claim --json
bd update bd-42 --priority 1 --json
```

**Complete work:**

```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task atomically**: `bd update <id> --claim`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" --description="Details about what was found" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`

### Auto-Sync

bd automatically syncs via Dolt:

- Each write auto-commits to Dolt history
- Use `bd dolt push`/`bd dolt pull` for remote sync
- No manual export/import needed!

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems

For more details, see README.md and docs/QUICKSTART.md.

<!-- END BEADS INTEGRATION -->
