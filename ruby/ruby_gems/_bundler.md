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

## Gemfile
##### requireオプション
- [Require As](https://bundler.io/v2.0/man/gemfile.5.html)

```ruby
gem "redis", :require => ["redis/connection/hiredis", "redis"]
gem "webmock", :require => false
```

- デフォルトで`Bundler.require`されているgemについて
  - `false`オプションでrequireを手動にする
  - 配列を渡してパスを指定する

#### platformsオプション
- [Platforms](https://bundler.io/v2.0/man/gemfile.5.html)
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
