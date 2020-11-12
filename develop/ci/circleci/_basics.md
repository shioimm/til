# CircleCI
- 参照: [CircleCI](https://circleci.com/docs/ja/2.0/about-circleci/#section=welcome)
- 参照・引用: WEB+DB PRESS Vol.107 ［Dockerもサポート！］実践CircleCI ワークフローで複雑なCI/CDを自動化 P10-40
- 参照・引用: CitrcleCI実践入門 第一章 / 第二章

## 特徴
- Dockerのサポート
  - Dockerコンテナ上でのビルドをサポート
  - 多様なプログラミング言語へのサポート
  - コンビニエンスイメージ - CircleCIが用意しているDockerイメージ
    - `circleci/`イメージ - 旧世代のコンビニエンスイメージ
    - `cimg/`イメージ - 新世代のコンビニエンスイメージ
- ワークフロー(パイプライン)
  - 並行実行により複雑な処理を行うことができる
- リソースクラス
  - CPUとメモリの柔軟な変更
- 従量課金
- CUI実行環境のサポート

### CircleCIでできること
- アプリケーションのビルド()
- アプリケーションのテスト/スタイルチェック
- アプリケーションのデプロイ

## 動作の流れ
1. ユーザーが変更をプッシュ
2. リモートリポジトリがWebhookでCircleCIへ更新を通知
3. 最新のコミットに対してCIの実行を開始
4. 各ジョブの実行
    - 失敗した場合はその時点でCIの実行を完了しリモートリポジトリに完了を通知
5. CIの実行を完了
6. CircleCIがリモートリポジトリに完了を通知

## Get Started
- `circleci-cli`のインストール
- `config.yml`の作成

## `config.yml`
- バージョン
- ジョブ
  - ステップ - コマンド
    - runステップ - ユーザー定義のシェルコマンド
    - ビルトインステップ - CircleCIが用意した特殊なステップ
  - Executor - ジョブの実行環境
    - Docker Executor - Dockerイメージ
    - Machine Executor - 仮想マシン環境
    - macOS Executor - Xcode + macOS環境
    - Windows Executor - Windows環境
- ワークフロー - ジョブの実行順序

```yml
# 基本
version: 2.0                     # version     CircleCIのバージョン
jobs:                            # jobs        ジョブ群の定義
  build:                         # buildジョブ 実行環境の設定
    docker:
      - image: circleci/node:12  # image       ビルドに使用するDockerイメージ
    steps:                       # steps       実行したい処理
      - run: yarn install        # run         ユーザーが指定するコマンド
      - run: yarn build
```
```yml
# restore_cache / save_cache
steps:
  - restore_cache: # restore_cache keyで指定されたキャッシュを復元
    keys:          # 上から一致するキャッシュを復元
      - v1-dependencies-{{ .Branch }}-{{ checksum "yarn.lock" }}
      - v1-dependencies-{{ .Branch }}
      - v1-dependencies
  - run: yarn install
  - save_cache:
    key: v1-dependencies-{{ .Branch }}-{{ checksum "yarn.lock" }}
    path:
      - node_modules
```
```yml
# persist_to_workspace / attach_workspace
version: 2
jobs:
  build:
    working_directory: ~/.repo
    docker:
        - image: circleci/node:12
    steps:
      - checkout
      - run: yarn install
      - persist_to_workspace: # persist_to_workspace ファイル共有元の設定
          root: ~/repo        # root                 ルートディレクトリの指定
          paths:              # paths                ファイル共有元のパス
            - node_modules/*
  test:
    working_directory: ~/repo
    docker:
      - image: circleci/node:8.11.3
    steps:
      - checkout
      - attach_workspace:     # attach_workspace    ファイル共有先の設定
          at: ~/repo          # at                  ファイル共有先のディレクトリ
```

### 主要なキー
#### Jobs
- [jobs](https://circleci.com/docs/ja/2.0/configuration-reference/#jobs)
  - 個々のジョブの定義(ジョブ名: 内容)
    - `build` - 実行環境のビルド
    - `steps` - 実行したい処理
- ステップの種類
- `run`
- `checkout`
- `setup_remote_docker`
- `save_cache`
- `restore_cache`
- `store_test_results` / `store_artifacts`
- `deploy`
- `persist_to_workspace` / `attach_workspace`
- `add_ssh_keys`
- ステップ内で使用できるキー
  - `when` / `unless`
  - `pre_steps` / `post_step`s

#### Commands
- [commands](https://circleci.com/docs/ja/2.0/configuration-reference/#commandsversion21-%E3%81%8C%E5%BF%85%E9%A0%88)
  - 複数のジョブ間で再利用可能なコマンド
    - `steps` - 必須
    - `parameters`
    - `description`
```yml
commands:
  hello:
    description: あいさつ
    parameters:
      to:
        type: string
        default: World
    steps:
      - run: echo Hello << parameters.to >>

jobs:
  steps:
    - hello:
      to: 'How are you?'
```

#### Executors
- [executors](https://circleci.com/docs/ja/2.0/configuration-reference/#executorsversion21-%E3%81%8C%E5%BF%85%E9%A0%88)
- 複数のジョブ間で再利用可能なジョブの実行環境の定義
```
executors:
  xxx_executor:
    docker:
      - image: circleci/node:12
jobs:
  build:
    executor: xxx_executor
```

#### Orbs
- [Orbs とは](https://circleci.com/docs/ja/2.0/orb-intro/)
> ジョブ、コマンド、Executorのような設定要素をまとめた共有可能なパッケージ

- ジョブ設定の再利用
- Orb Registory - Orbsの設定を保存するレジストリ

#### Workflows
- [workflows](https://circleci.com/docs/ja/2.0/configuration-reference/#workflows)
  - ジョブの実行順序の制御
```yml
jobs:
  build:
    docker:
      - image: circleci/node:12
  test:
    docker:
      - image: circleci/node:12
workflows:
  version: 2
  build_and_test:
    jobs:
      - build
      - test
```

### 使用できるオプションキー
- ジョブのオプション
  - `steps`で使用するシェル
  - `steps`で使用するワーキングディレクトリ
  - ジョブを実行する並列インスタンス数
  - 環境変数
- 実行環境(Docker)のオプション
  - 認証情報
- `run`ステップのオプション
  - シェルが実行できるコマンド
  - ステップのタイトルの設定

## 並列実行
### パラレルジョブ
- 同じジョブを二つ以上のコンテナで並列に実行する
  - テストを分割して並列実行中のコンテナに分散して実行する
    -> 実行時間が短縮できる
- 分割していない処理は同じ時間だけかかる
- 並列数を増やした分コンテナの消費数も増える
- `parallelism`キー
  - `circleci tests split --split-by=timings`
    -> テストファイルを並列実行数に合わせて自動的に分割

### マルチコンテナ
- 複数のコンテナを利用してジョブを並列実行する
  - ワークフローを駆使して複数コンテナでジョブを同時並列で実行する
    - 依存関係のない処理を常に実行できる
    -> 実行時間が短縮できる

## データの永続化
### ワークスペース
- 同一ワークフロー内のジョブ間でデータを共有する
- ジョブ内でワークスペースの使用を宣言することによって
  データを保存するためのレイヤーがワークスペース内に作成され、
  データを格納できる
- 以降のジョブでワークスペースに格納されているデータを使用することができる
- 異なるワークフローとの間でファイルを共有することはできない

### キャッシュ
- 異なるワークフロー内のジョブ間でデータを共有する
- ジョブが終わってもデータが永続化されている

### アーティファクト
- ジョブの実行結果を保存するためのストレージ
- 異なるワークフローやジョブとは共有しないデータの永続化に適している

### パイプライン
- 複数のワークフローを包括する概念
  - ワークフロー - ジョブの実行順序の制御
  - ジョブ - ステップの集まり
  - ステップ - コマンドを実行する最小単位

## 環境変数
- [定義済み環境変数](https://circleci.com/docs/ja/2.0/env-vahttps://circleci.com/docs/ja/2.0/env-vars/#%E5%AE%9A%E7%BE%A9%E6%B8%88%E3%81%BF%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0rs/#%E5%AE%9A%E7%BE%A9%E6%B8%88%E3%81%BF%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0)
- インライン環境変数
  - `config.yml`に`environment`キーを定義する
```yml
environment:
  XXX: xxx
```
