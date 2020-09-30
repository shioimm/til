# CircleCI
- 参照: [CircleCI](https://circleci.com/docs/ja/2.0/about-circleci/#section=welcome)
- 参照: WEB+DB PRESS Vol.107 ［Dockerもサポート！］実践CircleCI
ワークフローで複雑なCI/CDを自動化 P10-40

## 特徴
- コマンドによるローカル実行環境を用意している
- Dockerを標準でサポートしており、Docker環境でCIを実行する
- ワークフロー(並列実行)による複雑な処理を行うことができる

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

### `config.yml`
- 引用・参照: [設定の概要](https://circleci.com/docs/ja/2.0/config-intro/)
- `.circleci/config.yml`を通じ、ビルドからデプロイまでのデリバリープロセス全体が組織化される
```yml
version: 2.0                # version     CircleCIプラットフォームのバージョン
jobs:                       # jobs        配下にジョブのコレクションを格納
 Hello-World:               # Hello-World Hello-Worldジョブ
   build:                   # build       buildジョブ
     docker:
       - image: alpine:3.7  # image    ビルドジョブに使用するDockerイメージへの参照を追加
     steps:                 # steps    runディレクティブの順序付きリストを格納
       - checkout           # checkout checkoutコマンド - 後続のステップで使用するためのブランチコードを自動的に取得
       - run:               # run      宣言順に実行する
           name: 最初の一歩
           command: |       # command  実行する作業を表すシェルコマンドのリスト
             echo 'Hello World'
      - run:
           name: コードの取得
           command: |
             ls -al  # チェックアウトの内容をls -al でリスト
  Run-With-Node:     # Run-With-Node Run-With-Nodeジョブ
   docker:
     - image: circleci/node:10-browser
   steps:
     - run:
          name: 独自コンテナで実行
          command: |
            node -v

workflows:
 version: 2
 Example_Workflow:
   jobs:
     - Hello-World
     - Run-With-Node:
         requires:
           - Hello-World # Hello-Worldジョブの完了を待って実行
```

#### Job
- [jobs](https://circleci.com/docs/ja/2.0/configuration-reference/#jobs)
> 実行処理は 1 つ以上の名前の付いたジョブで構成され、それらのジョブの指定は jobs マップで行う
> Workflows を利用する際は、.circleci/config.yml ファイル内でユニークなジョブ名を設定
> Workflows を 使わない 場合は、jobs マップ内に build という名前のジョブを用意

#### Command
- [commands](https://circleci.com/docs/ja/2.0/configuration-reference/#commandsversion21-%E3%81%8C%E5%BF%85%E9%A0%88)
> ジョブ内で実行するステップシーケンスをマップとして定義

#### Executor
- [executors](https://circleci.com/docs/ja/2.0/configuration-reference/#executorsversion21-%E3%81%8C%E5%BF%85%E9%A0%88)
> ジョブステップの実行環境を定義

#### Orbs
- [Orbs とは](https://circleci.com/docs/ja/2.0/orb-intro/)
> ジョブ、コマンド、Executorのような設定要素をまとめた共有可能なパッケージ

#### Workflows
- [workflows](https://circleci.com/docs/ja/2.0/configuration-reference/#workflows)
> あらゆるジョブの自動化に用いる
