# ワークフロー
- 参照: [CircleCI](https://circleci.com/docs/ja/2.0/about-circleci/#section=welcome)
- 参照・引用: CitrcleCI実践入門 第四章

## ワークフローでできること
- ジョブのオーケストレーション
  - シーケンシャルジョブ - 複数ジョブを連続実効
  - ファンアウト - 共通ジョブを実行 -> 複数ジョブを複数コンテナで並列実行
  - ファンイン - 複数ジョブを複数コンテナで並列実行 -> 共通ジョブを実行
- ジョブ間のファイル共有(ワークスペースによる)
- スケジューリングジョブ
- フィルタリング(Gitタグ、ブランチによる)
- 環境変数の共有(コンテキストによる)

## ワークフローの構成要素
- バージョン
- ワークフロー名
- ジョブのリスト
  - 必ず`build`ジョブを含む

## ワークフローのステータス
- `RUNNING`
- `NOT RUN`
- `CANCELLED`
- `FAILING`
- `FAILED`
- `SUCCESS`
- `ON HOLD`
- `NEEDS SETUP`

## ジョブの再利用
### `executors`
- 実行環境を保存するExecutor機能を設定するキー
```yml
version: 2.1

# Executorを設定
executors:
  myexecutor:
    docker:
      - image: cimg/ruby:2.7.1-node
    environment:
      BUNDLE_PATH: vendor/bundle

# Executorを利用
jobs:
  build:
    executor: myexecutor
    environment: #ジョブ内で上書きも可能
      RAILS_ENV: production
    steps:
      - run: echo 'Hello'
```

```yml
# OrbのExecutorを使用
version: 2.1

# Orbのインポート
orbs:
  win: circleci/windows@2.4.0

# Orb内で定義されているExecutorを利用
jobs:
  build:
    executor: win/defailt
    steps:
      - run: echo 'Hello'
```

### `commands`
- ステップを切り取るキー
```yml
version: 2.1

# commandsを定義
commands:
  echohello:
    steps:
      - run echo 'Hello'

# commandsを利用
jobs:
  build:
    docker:
      - image: cimg/node:lts
    steps:
      - echohello
```

```yml
version: 2.1

# 引数を使用するcommandsを定義
commands:
  echohello:
    description: "Echo Hello"
    parameters:
      to:
        type: string
        default: "World"
    steps:
      - run echo Hello << parameters.to >>

# commandsに引数を渡す
jobs:
  build:
    docker:
      - image: cimg/node:lts
    steps:
      - echohello
        to: John
```

