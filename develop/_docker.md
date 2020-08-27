# Docker
- 参照: [Docker](https://www.docker.com/)
- 参照: [Docker 概要](https://docs.docker.jp/get-started/overview.html)
- 参照: [Docker入門（第一回）～Dockerとは何か、何が良いのか～](https://knowledge.sakura.ad.jp/13265/)
- 参照: [Docker入門（第二回）～Dockerセットアップ、コンテナ起動～](https://knowledge.sakura.ad.jp/13795/)
- 参照: [Docker入門（第四回）～Dockerfileについて～](https://knowledge.sakura.ad.jp/15253/)
- 参照: [Dockerイメージの理解とコンテナのライフサイクル](https://www.slideshare.net/zembutsu/docker-images-containers-and-lifecycle)

## TL;DR
- コンテナのライフサイクルを管理するツールとプラットフォーム
  - コンテナ - ホストマシン上で他のプロセスから隔離された環境

### アプリケーション開発におけるコンテナ
- コンテナを利用してアプリケーションおよび関連のコンポーネントを開発する
- コンテナをアプリケーションの配布とテストを行う１つの単位として利用する
- コンテナ単位あるいはオーケストレーション単位でアプリケーションをデプロイする

### 構成要素
- Dockerイメージ
  - Dockerコンテナを作成する命令が入った読み込み専用のテンプレート
    - Dockerfileを使って自作する
    - コンテナの内容を手動でコミットし新しいイメージを作成する
    - Docker Hubから公開されているイメージを取得する

- Dockerコンテナ
  - イメージが実行状態となったインスタンス
  - イメージによって定義され、削除時に永続的なストレージに保存されていないものは消失する

- Docker Engine
  - Dockerコンテナを移動・実行するためのクライアント-サーバー型アプリケーション
  - DockerクライアントがDockerデーモンに処理を依頼
    -> DockerデーモンがDockerコンテナの構築、実行、配布を行う
    - Dockerクライアント - `docker`コマンド / Dockerデーモンの制御を行う
    - Dockerデーモン     - `dockerd`コマンド / Dockerオブジェクトを作成、管理する
      - Dockerオブジェクト - イメージ、コンテナ、ネットワーク、データ・ボリューム

#### ツール
- Docker Hub         - [コンテナイメージ共有リポジトリ](https://www.docker.com/products/docker-hub)
- Docker Desktop     - デスクトップアプリケーション
- Dockerfile         - Dockerイメージを作成するためのDSLを記述する
- .dockerignore      - ホストに存在しているが、Dockerイメージには組み込みたくないファイル群を記述する
- docker-compose.yml - 複数のコンテナイメージを組み合わせて起動するdocker-composeの設定ファイル

### 仮想マシンとの違い
- 仮想マシン
  - ホストマシン上でハイパーバイザを利用してゲストOSを動かし、その上でミドルウェアなどを動かす
- Docker
  - ホストマシンのカーネルを利用し、プロセスやユーザなどを隔離することによって
    別のマシンが動いているかのように動かす
  - ミドルウェアのインストールや各種環境設定はコード化して管理する(IaC)

### 利点
- コード化されたファイルを共有することで、同じ環境を容易に作ることができる
- 作成した環境を容易に破棄したり新たに作成することができる
- 作成した環境を容易に配布できる

## ライフサイクル
1. Dockerイメージを取得
2. DockerイメージをDocker Engine上でrun
3. Dockerコンテナが起動
4. - 略 -
5. Dockerコンテナを削除
6. Dockerイメージを削除

## コマンド
- [コマンドライン・リファレンス](https://docs.docker.jp/compose/reference/toc.html)
```
# Dockerイメージをビルド
$ docker build [ -t ｛イメージ名｝ [ :{タグ名} ] ] {Dockerfileのあるディレクトリ}

# Dockerコンテナを起動
$ docker run [オプション] [--name {コンテナー名}] {イメージ名}[:{タグ名}] [コンテナーで実行するコマンド] [引数]

# docker-composeを立ち上げる
# -dオプションでデーモン化
$ docker-compose up [オプション] [サービス...]

# docker-composeでコマンドを実行
$ docker-compose run [-f=<引数>...] [オプション] [コマンド] [引数...]

# docker-composeで立ち上げた環境を(DBに保存されたデータごと)捨てる
$ docker-compose down [オプション]
```
