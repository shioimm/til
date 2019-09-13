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
