# Docker
- 参照: [Docker](https://www.docker.com/)
- 参照: [Docker入門（第一回）～Dockerとは何か、何が良いのか～](https://knowledge.sakura.ad.jp/13265/)
- 参照: [Docker入門（第二回）～Dockerセットアップ、コンテナ起動～](https://knowledge.sakura.ad.jp/13795/)
- 参照: [Docker入門（第四回）～Dockerfileについて～](https://knowledge.sakura.ad.jp/15253/)
- 参照: [Dockerイメージの理解とコンテナのライフサイクル](https://www.slideshare.net/zembutsu/docker-images-containers-and-lifecycle)

## TL;DR
- コンテナ型の仮想環境でアプリケーションを開発・移動・実行するためのプラットフォーム
- コンテナ化されたアプリケーションは実行環境に関わらず常に同じように実行される

### 構成要素
- Dockerコンテナ - コンテナ
- Docker Engine  - Dockerコンテナを移動・実行するために必要なプログラム(デーモン)
- Dockerイメージ - コンテナの実行に必要なファイルシステム
  - Dockerfileを使って自動構築する
  - コンテナの内容を手動でコミットし新しいイメージを作成する
  - Docker Hubから公開されているイメージを取得する

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
