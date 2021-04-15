# GitHub Actions
- 参照: [GitHub Actionsについて](https://docs.github.com/ja/actions/getting-started-with-github-actions/about-github-actions)
- 参照: パーフェクトRuby on Rails[増補改訂版] P406-410

## TL;DR
- GitHubに組み込まれた継続的インテグレーションサービス
- 継続的インテグレーション(CI)と継続的デプロイメント(CD)機能を直接リポジトリにビルドすることができる

## ワークフローの作成
### ソース
- リポジトリで定義されているアクション
- GitHub上のパブリックなリポジトリにあるOSSのアクション
- 公開されているDockerコンテナイメージ

### 設定ファイル
- `/.github/workflows/xxx(開発言語).yml`ファイルに記述する
  - GitHubリポジトリ上から追加することができる

```yml
name: Rails Tests
on: [push, pull_request]         # ワークフローをトリガーするイベント
jobs:
  build:
    runs_on: ubuntu-latest       # 実行環境のOSを指定
    steps:                       # ステップごとに独立したプロセスとして動作
    - users: actions/checkout@v2
    - name: Set up Ruby 2.6
      uses: ruby/setup-ruby@v1   # 任意のバージョンのRuby実行環境を用意するアクション
      with:
        ruby-version: 2.6        # 利用するRubyのバージョン
    - name: Build and test
      env:
        RAILS_ENV: test
      run: |                     # OSのシェル上で実行するコマンド
        sudo apt-get -yqq install libsqlite3-dev # DBのインストール
        bundle install
        bin/rails db:create
        bin/rails db:migrate
        bin/yarn install
        bin/rails test
        bin/rails test:system
```
