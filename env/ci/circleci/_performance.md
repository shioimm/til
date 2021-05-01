# 速度改善
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
- キャッシュの保存期間は30日
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

#### テンプレート
- `{{ checksum "ファイル名" }}`
  - ロックファイルを指定して依存パッケージやランタイムの更新を監視
  - OSの変更は検知できない
- `{{ arch }}`
  - クロスプラットフォームでも安全性の高いキャッシュを作成
  - クロスプラットフォーム以外は変化しない
- `{{ .Environment.環境変数名 }}`
  - プロジェクト設定やコンテキストの環境変数を使って`config.yml`を変更せずにキャッシュキーを変更
  - ビルトイン環境変数とプロジェクト設定、コンテキスト以外の環境変数は利用できない
- `{{ .Branch }}`
  - ブランチごとのキャッシュを作成
- `{{ .Revision }}`
  - コミットごとのキャッシュを作成
  - 再実行と同一ワークフロー以外はキャッシュを復元できない
- `{{ .BuildNum }}`
  - ジョブごとのキャッシュを作成
  - 同一ジョブ以外はキャッシュを復元できない
- `{{ epoch }}`
  - 必ずキャッシュを作成
  - キャッシュキーのヒットしない

### Dockerイメージキャッシュ
- Dockerイメージをビルドする際の各レイヤをキャッシュ
  -> `$ docker build` / `$ docker compose`の実行時間を短縮
  - CircleCIのDockerレイヤキャッシュを利用する
- Dockerイメージをビルドした際に作成されたレイヤを以後の同ジョブに引き継ぐ
  - ジョブの終了後の使用可能なボリュームを用意し、
    Executorのファイルシステムにアタッチして再利用できるようにする
```yml
version: 2.1
jobs:
  dlc_job:
    machine:
      docker_layer_caching: true
```

```yml
- setup_remote_docker:
  docker_layer_caching: true
```

## ジョブ内並列実行
- 同じジョブを同時に複数のコンテナで実行させ、
  処理するテストファイルを書くコンテナに分配することで
  実行時間を短縮する
  - 有料プランの利用
  - 通常はジョブ単体の実行は単一のコンテナで実行される
- `$ circleci tests glog` - テストファイル一覧取得
- `$ circleci tests split` - テストファイル一覧を並列実行数に応じて分割
  - `--split-by` - `name`(ファイル名) / `filesize`(ファイルサイズ) / `timings`(実行時間)
```yml
version: 2
jobs:
  build:
    docker:
      - image: cimg/node:lts
    steps:
      - checkout
      - run:
        name: テストファイル分割1
        command: |
          circleci tests glog "__tests__/*.ts" | \
          circleci tests split --total2 --index=0
      - run:
        name: テストファイル分割2
        command: |
          circleci tests glog "__tests__/*.ts" | \
          circleci tests split --total2 --index=1
```

## リソースクラスの変更
- 仮想ハードウェアリソースをジョブ単位で選択
  - ジョブを実行するExecutorのCPUやメモリサイズを設定することができる
  - small / medium / large ...
```yml
text_jest:
  executor: default
  recource_class: large
  steps:
    - checkout
```

## 参照・引用
- [CircleCI](https://circleci.com/docs/ja/2.0/about-circleci/#section=welcome)
- CitrcleCI実践入門 第六章
