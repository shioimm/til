# CircleCI
- 参照: [CircleCI](https://circleci.com/docs/ja/2.0/about-circleci/#section=welcome)

## 設定
- 参照: [Ruby on Rails set up on Github with CircleCI](https://hixonrails.com/ruby-on-rails-tutorials/ruby-on-rails-set-up-on-github-with-circleci/)
1. GitHubアカウントで[CircleCI](https://circleci.com/signup/)に登録
2. Add Projectタブを選択
3. Set up projectボタンを押下
4. アプリケーションの`/`直下に`config/database.yml`を作成
5. アプリケーションの`/`直下に`.circleci/config.yml`を作成
    - 基本の設定を記述
    - RSpecの設定を追加
    - Rubocopの設定を追加
- 参考: [はじめに](https://circleci.com/docs/ja/2.0/getting-started/#section=getting-started)

### 設定概要
- 引用・参照: [設定の概要](https://circleci.com/docs/ja/2.0/config-intro/)
- `.circleci/config.yml`を通じ、ビルドからデプロイまでのデリバリープロセス全体が組織化される
```yml
version: 2.0                    # version     CircleCIプラットフォームのバージョン
jobs:                           # jobs        配下にジョブのコレクションを格納
 Hello-World:                   # Hello-World Hello-Worldジョブ
   build:                       # build       buildジョブ
     docker:
       - image: alpine:3.7      # image    ビルドジョブに使用するDockerイメージへの参照を追加
     steps:                     # steps    runディレクティブの順序付きリストを格納
       - checkout               # checkout checkoutコマンド - 後続のステップで使用するためのブランチコードを自動的に取得
       - run:                   # run      宣言順に実行する
           name: 最初の一歩
           command: |           # command  実行する作業を表すシェルコマンドのリスト
             echo 'Hello World'
      - run:
           name: コードの取得
           command: |
             ls -al             # チェックアウトの内容をls -al でリスト
  Run-With-Node:                # Run-With-Node Run-With-Nodeジョブ
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
           - Hello-World        # Hello-Worldジョブの完了を待って実行
```

## 設定要素
### Job
- [jobs](https://circleci.com/docs/ja/2.0/configuration-reference/#jobs)
> 実行処理は 1 つ以上の名前の付いたジョブで構成され、それらのジョブの指定は jobs マップで行う
> Workflows を利用する際は、.circleci/config.yml ファイル内でユニークなジョブ名を設定
> Workflows を 使わない 場合は、jobs マップ内に build という名前のジョブを用意

### Command
- [commands](https://circleci.com/docs/ja/2.0/configuration-reference/#commandsversion21-%E3%81%8C%E5%BF%85%E9%A0%88)
> ジョブ内で実行するステップシーケンスをマップとして定義

### Executor
- [executors](https://circleci.com/docs/ja/2.0/configuration-reference/#executorsversion21-%E3%81%8C%E5%BF%85%E9%A0%88)
> ジョブステップの実行環境を定義

### Orbs
- [Orbs とは](https://circleci.com/docs/ja/2.0/orb-intro/)
> ジョブ、コマンド、Executorのような設定要素をまとめた共有可能なパッケージ

### Workflows
- [workflows](https://circleci.com/docs/ja/2.0/configuration-reference/#workflows)
> あらゆるジョブの自動化に用いる
