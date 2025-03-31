---
layout: post
title: DependabotのPRにフックして追いcommitする
tags: [Dependabot, Nix, GitHub Actions]
thumb: yes
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡

寒すぎる｡俺達の春を返せよ…｡

# はじめに
本ブログはJekyllで運用されており､GitHubでホストされ､Dependabotで依存ライブラリのアップデートを最近自動化した｡

ところで､このシステムでは開発にNixを使っており､[ruby-nix](https://github.com/inscapist/ruby-nix)によってRubyの依存ライブラリをNix化している｡
[bundix](https://github.com/Nymphium/nymphium.github.io/blob/75e1119fbc2e3effc73efcc47feb8e87ff477b78/nix/bundix.nix)でGemfile.lockからgemset.nixを生成し､ruby-nixでNix化されたgemsのパスが通っているshellが動いており､そこで開発をおこなう｡

でもよぉDependabotのPRではgemset更新してくれないやんけ､ということで↓をやりたい｡

1. DependabotがGemfile{,.lock}更新のPRが出たら
2. PRにhookして
    1. gemset.nixを更新して
    2. PR branchにpushする

# hook やりかた
DependabotのPRがどういう挙動をするかを確認する｡
例えばこのPR:
{% twicard "" https://github.com/Nymphium/nymphium.github.io/pull/65 %}

- `dependabot[bot]`というユーザがPRを作り[^1]
- `dependencies` `ruby` というラベルをつける

ふむ｡
PRにラベルがついたときにGitHub Actionsを発火させられるので､それをやるとよい｡

```yaml :.github/workflows/dependabot-hook.yml
on: 
  pull_request:
    types: [labeled]
```

ちょっと丁寧に､`dependabot`というユーザが`dependencies` `ruby` ラベルをつけたときに絞る｡

```yaml :.github/workflows/dependabot-hook.yml
jobs:
  hook:
    if: |
        github.event.label.name == 'dependencies' &&
        github.event.label.name == 'ruby' &&
        github.actor == 'dependabot[bot]'
    runs-on: ubuntu-latest
    steps:
      - ...
```

`ruby`以外にもhookしたい環境がある場合便利ですな｡

# やるだけ

あとはやるだけ｡
bundixでgemsetを更新し､PR branchにcommit & pushする｡

```yaml :.github/workflows/dependabot-hook.yml
- run: nix run '.#patched-bundix' # gmsetを更新
- run: |
    git config --global user.name 'github-actions[bot]'
    git config --global user.email 'github-actions[bot]@users.noreply.github.com'
    git commit --all -m "Update gemset.nix via bundix" || echo "No changes to commit"
    git fetch origin
    git rebase origin/${{ github.event.pull_request.head.ref }} || git merge origin/${{ github.event.pull_request.head.ref }}
    git push "https://${GITHUB_ACTOR}:${{ secrets.GITHUB_TOKEN }}@github.com/${GITHUB_REPOSITORY}.git" ${{ github.event.pull_request.head.ref }}:refs/heads/${{ github.event.pull_request.head.ref }}
```

ユーザ名とemailは適当で良いが､無いとcommitできないので設定しておく｡
`${GITHUB_ACTOR}` は自動で設定されており､PRのauthorに同じ `dependabot[bot]`｡
`${{ secrets.GITHUB_TOKEN }}` もGithub Actionsで自動で発行されるトークンで､リポジトリに閉じた権限で使える｡

こういう賢いactionsを使ってもいいかもしれない｡

{% twicard "" https://github.com/marketplace/actions/github-push %}

PRに書き込むために､permissionを設定する必要があるので､やる

```yaml :.github/workflows/dependabot-hook.yml
permissions:
  contents: write
  actions: write
  pull-requests: write
```

なんか多くね? まあ一旦ええか､一旦…｡

これでPRにhookして自動でgemsetが更新される｡

{% twicard "" https://github.com/Nymphium/nymphium.github.io/pull/74/commits/c2bb00e1782dced565eaa4a3b880722cb2316cbb %}

ええな｡

# おわりに
Dependabotがhookサポートしてくれねえかな…｡

---

この記事は業務時間中に書かれた｡
株式会社eiiconではCIとNixのノウハウが豊富な人材を募集しています｡

{% twicard "" https://corp.eiicon.net/career/tfixCb-R %}

本記事で使われたテクニックはプロダクトの開発でも利用されている｡

[^1]: commitを見るとユーザ名がわかる｡彼の本名は `dependabot[bot]`
