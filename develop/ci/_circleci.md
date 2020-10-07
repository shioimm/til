# CircleCI
- 参照: [CircleCI](https://circleci.com/docs/ja/2.0/about-circleci/#section=welcome)
- 参照・引用: WEB+DB PRESS Vol.107 ［Dockerもサポート！］実践CircleCI
ワークフローで複雑なCI/CDを自動化 P10-40

## 特徴
- コマンドによるローカル実行環境を用意している
- Dockerを標準でサポートしており、Docker環境でCIを実行する
- ワークフロー(並列実行)による複雑な処理を行うことができる
  - 一つのジョブを一つのコンテナで実行
  - 無料で使用できるコンテナ数には限りがある
- CircleCI自身が各種言語やミドルウェアのプリビルドイメージをDocker Hubに用意しているため、
  ビルド環境の構築が容易

### CircleCIでできること
- アプリケーションのビルド
- アプリケーションのテスト/スタイルチェック
- アプリケーションのデプロイ

## 動作の流れ
1. リポジトリの更新を検知
2. CIの実行を開始
3. 各ジョブの実行
    - 失敗した場合はCIの実行を完了しリポジトリに完了を通知
4. CIの実行を完了
5. リポジトリに完了を通知

## ワークフロー
- 実行ステップをジョブという単位に分解し、
  ジョブの実行に必要な条件を付与することで実行順を制御する
  - 連続実行(ステップ実行と同じ)
  - ファンアウト(一つのジョブ完了後に複数のジョブを実行)
  - ファンイン(複数のジョブ完了後に一つのジョブを実行)
  - スケジューリング(定期実行)
  - ブランチ別ジョブ実行(Gitのブランチ名でフィルタリング)
  - タグ別ジョブ実行(Gitのタグ名でフィルタリング)

## Get Started
- `circleci-cli`のインストール
- `config.yml`の作成

## `config.yml`
- 引用・参照: [設定の概要](https://circleci.com/docs/ja/2.0/config-intro/)
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
  - 一つ以上のジョブの定義(ジョブ名: 内容)
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

#### Workflows
- [workflows](https://circleci.com/docs/ja/2.0/configuration-reference/#workflows)
  - 一連のジョブとその実行順序を定義するルール
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
