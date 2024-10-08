# Gemfile
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

#### pathオプション
- [Path](https://bundler.io/v2.0/man/gemfile.5.html#PATH)
- ローカルのgemを指定する
```
gem 'toycol', path: "../../" # `gemname`.gemspecが置いてあるパスを指定する
```
