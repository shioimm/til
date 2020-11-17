# 速度改善
- 参照: [CircleCI](https://circleci.com/docs/ja/2.0/about-circleci/#section=welcome)
- 参照・引用: CitrcleCI実践入門 第六章

## 複数ジョブの同時実行
- ジョブは並列に実行される
- 依存関係がないジョブは同時実行することで実行時間を短縮できる
- ジョブ同士の依存関係を整理し、不要なジョブ間の依存を排除する
