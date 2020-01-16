# Bundler
- プロセス単位でライブラリが混ざらないようにアイソレートするライブラリ
  - rubygemsでできないことをできるようにするためのラッパーツール(1/16 2020 銀座Rails)
    - rubygemsと統合していく予定(リポジトリもrubygems.orgに移行した)
    - rubygemsとBundlerでDependency Resolverのバージョンが違う
      - `gem install`したときとGemfileを使用した時で依存関係が変わる可能性がある

#### gemの内部実装を確認したい
- [bundle open](https://bundler.io/v1.10/bundle_open.html)

#### Gemfileから最新でないgemを探す
- [bundle outdated](https://bundler.io/man/bundle-outdated.1.html)

#### gemを最新にupdateする
- [bundle update](https://bundler.io/v2.0/man/bundle-update.1.html)
- `-g`オプションで特定のグループのみupdateできる
```
bundle update -g development -g test
```

#### gemの依存関係をビジュアライズする
- [bundler viz](https://bundler.io/v2.0/man/bundle-viz.1.html)

## `.bundle`
- `config` -> Bundlerに関する設定を記述できる
  - ex. `BUNDLE_PATH=vendor/bundle` -> デフォルトで`vendor/bundle`以下にgemがインストールされる

## Gemfile
#### gitオプション
- [Github](https://bundler.io/v2.0/man/gemfile.5.html#GITHUB)
```ruby
gem 'rails_admin', github: 'me/my_hogehoge', branch: 'master'
```
- githubオプション -> リポジトリを指定する
  - 例: リポジトリをフォークした場合
  - 例: ブランチを指定したい場合
- branchオプション -> branchを指定する
  - 例: masterへの変更がまだ`rake release`されていなかった場合
  - 例: フォークした先で別のブランチを切った場合

#### requireオプション
- [Require As](https://bundler.io/v2.0/man/gemfile.5.html#REQUIRE-AS)

```ruby
gem "redis", :require => ["redis/connection/hiredis", "redis"]
gem "webmock", :require => false
```

- デフォルトで`Bundler.require`されているgemについて
  - `false`オプションでrequireを手動にする
  - 配列を渡してパスを指定する

#### platformsオプション
- [Platforms](https://bundler.io/v2.0/man/gemfile.5.html#PLATFORMS)
- 処理系を特定する

```
ruby / mri  -> C Ruby (MRI), Rubinius or TruffleRuby, but NOT Windows
mingw       -> Windows 32 bit 'mingw32' platform (aka RubyInstaller)
x64_mingw   -> Windows 64 bit 'mingw32' platform (aka RubyInstaller x64)
rbx         -> Rubinius
jruby       -> JRuby
truffleruby -> TruffleRuby
mswin       -> Windows
```
