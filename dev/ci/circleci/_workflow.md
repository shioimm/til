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
## 複数ジョブの同時実行
### `requires`
```yml
# procces_common実行後にprocess_a/process_bを並行に実行
workflows:
  version: 2.1
  workflows:
    jobs:
      - procces_common # 先に実行する処理
      - process_a
        - requires:
          - procces_common # procces_common実行後に開始
      - process_b
        - requires:
          - procces_common # procces_common実行後に開始
```

## ジョブ間のファイル共有
- ワークスペース - ジョブが共有できるファイルのストレージ
  - 同一ワークフローの上流ジョブから下流ジョブへデータを渡す
  - 上流ジョブは下流ワークスペースを継承できない
  - 同名ファイルを上書きした場合、下流ジョブのファイルが使用される
  - 同時実行ジョブで同名ファイルを永続化した場合、ワークスペースの展開ができない

### `persist_to_workspace`
- ワークスペースに永続化するファイルの宣言
```yml
- persist_to_workspace:
  root: /tmp/dir # ルートディレクトリ
  paths: # 永続化したいファイル・ディレクトリ
    - foo/bar
    - baz/*
```

### `attach_workspace`
- ジョブからワークスペースにアクセスし、ジョブのコンテナ内にダウンロードを行う
```yml
- attach_workspace:
  at: /tmp/dir # ダウンロードするファイルの指定
```

## フィルタリング
### `filters`
- ワークフローを実行したいコミットタグ・ブランチを正規表現で指定できる
```yml
workflows:
  versions: 2
  build_workflow:
    jobs:
      - deploy:
        filters:
          tags:
            only: /^v.*/
          branches:
            ignore: /.*/
```

## スケジュール
### `cron`
- cronを用いてワークフローの定期実行を行う
- どのコミットに対してワークフローを実行するか`filters`キーで指定する
```yml
workflows:
  versions: 2
  build_workflow:
    triggers:
      - schedule:
        cron: "0 0 * * *" # 毎日00:00(UTC)に実行
        filters:
          branches:
            only:
              - master
    jobs:
      - build_job
```

## 承認ジョブ
### `type: approval`
- ジョブ実行に手動承認を要求する
```yml
version 2.1
jobs:
  build:
    docker:
      - image: busybox
    steps:
      - run: echo "build"
  deploy:
    docker:
      - image: busybox
    steps:
      - run: echo "deploy"

workflows:
  version: 2
  build-and-deploy:
    jobs:
      - build
      - hold: # 待機用ジョブ
        type: approval
        requires:
          - build
      - deploy:
        requires:
          - hold
```
