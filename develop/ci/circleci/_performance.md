# 速度改善
- 参照: [CircleCI](https://circleci.com/docs/ja/2.0/about-circleci/#section=welcome)
- 参照・引用: CitrcleCI実践入門 第六章

## 複数ジョブの同時実行
- ジョブは並列に実行される
- 依存関係がないジョブを同時実行することで実行時間を短縮する
- ジョブ同士の依存関係を整理し、不要なジョブ間の依存を排除する

## キャッシュ
- 転送されたデータを保存し、同じデータが必要になった時にキャッシュから読み取る
  - 転送時間や計算時間を省略する

### ファイルキャッシュ
- 実行中のジョブコンテナの中にあるファイル・ディレクトリをキャッシュ
  -> ファイルのダウンロード・コンパイル時間を短縮
- キャッシュの保存・復元時の転送時間がコストとなる
```yml
steps:
  - checkout
  - restore_cache: # キャッシュキーがヒットがあればキャッシュを復元
    name: キャッシュの復元
    keys:
      - v1-bundle-{{ checksum "Gemfile.lock" }}
  - run:
    name: gemのインストール
    command: bundle check --path vendor/bundle || bundle install --path vendor/bundle
  - save_cache: # キャッシュキーに変更があればキャッシュを保存
    name: キャッシュの保存
    key: v1-bundle-{{ checksum "Gemfile.lock" }}
    paths:
      - vendor/bundle
```

### Dockerイメージキャッシュ
- Dockerイメージをビルドする際の各レイヤをキャッシュ
  -> `$ docker build` / `$ docker compose`の実行時間を短縮
  - CircleCIのDockerレイヤキャッシュを利用する

## ジョブ内の並列実行
- 有料プランの利用

## リソースクラスの変更
- マシンリソースの不足に起因する問題を解決
