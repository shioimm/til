# Usage
```
# gemのソースディレクトリをエディタで開く
# (環境変数EDITORまたはBUNDLER_EDITORの設定が必要)
$ bundle open GEM

# 最新バージョンでないgemを特定する
$ bundle outdated

# gemを最新にupdateする
$ bundle update *GEMS

# (特定のグループをまとめてupdateする)
$ bundle update -g development -g test

# bundlerディレクトリにある未使用のgemをGemfileから削除する
# (システムレベルのgemを使用していて、複数のRubyプロジェクトで同じgemが使われている場合、
#  現在のプロジェクトで使用されていないグローバルなgemが削除される)
$ bundle clean

# gemの依存関係をビジュアライズする
$ bundle viz

# Bundlerに関するデフォルト設定を.bundle/config内に記述する
$ bundle config
```

## 参照
- [bundle open](https://bundler.io/v1.10/bundle_open.html)
- [bundle outdated](https://bundler.io/man/bundle-outdated.1.html)
- [bundle update](https://bundler.io/v2.0/man/bundle-update.1.html)
- [bundle clean](https://bundler.io/man/bundle-clean.1.html)
  - [Spring Cleaning: Tidying up your codebase](https://boringrails.com/articles/spring-cleaning/)
- [bundler viz](https://bundler.io/v2.0/man/bundle-viz.1.html)
- [bundle config](https://bundler.io/v2.1/bundle_config.html)
