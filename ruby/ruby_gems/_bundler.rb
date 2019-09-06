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
