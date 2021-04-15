# Quic Start
- 参照: [クィックスタート: Compose と Rails](https://docs.docker.jp/compose/rails.html)

## 1. プロジェクトの定義
- ルート直下にファイルを置く

### Docker用設定ファイル
- Dockerfile
- docker-compose.yml
- .dockerigore
  - ホストには存在しているがDockerイメージには組み込みたくないファイル群
  - `.git` / `vendor/bundle` / `log/` / `tmp/`

### Rails用初期化ファイル(`$ rails new`時に置き換えられる)
- 初期化用Gemfile
  - `rails` gemのみ記述
- 空のGemfile.lock

## 2. プロジェクトのビルド
```
# ComposeがDockerfileを使用してwebサービスのイメージをビルド
#   ビルドされたイメージを使用して生成されたコンテナ内でrails newを実行
#   プロジェクトディレクトリはコンテナにマウントされる
$ docker-compose run web rails new . --force --database=postgresql

# rails newで置き換えられたGemfileを元にイメージを再ビルド
$ docker-compose build
```

## 3. データベースの接続設定
1. config/database.ymlの設定を変更
    - docker-compose.ymlに設定した`db`サービスを使用するよう変更
    - `postgres`イメージに設定されているデフォルトのデータベース名、ユーザ名を変更
2. Composeの立ち上げ `$ docker-compose up`
3. DB生成 `$ docker-compose run web rake db:create`

## 4. Rails の「ようこそ」ページの確認
- 指定したローカルホストにてアプリケーションの起動を確認できる

## 5. アプリケーションの停止
- Composeのの停止 `$ docker-compose down`

## 6. アプリケーションの再起動
1. `$ docker-compose up`
2. `$ docker-compose run web rake db:create`

# サンプル
- 引用・参照: [クジラに乗ったRuby: Evil Martians流Docker+Ruby/Rails開発環境構築（翻訳）](https://techracho.bpsinc.jp/hachi8833/2019_09_06/79035)
## 環境
- Ruby 2.6.3
- PostgreSQL 11
- NodeJS 11 & Yarn（Webpackerベースのアセットコンパイル用）

## Dockerfile
- 開発時に必要な設定の記述
  - サーバーの実行、コンソール、テスト、rakeタスク
```
ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION

ARG PG_MAJOR
ARG NODE_MAJOR
ARG BUNDLER_VERSION
ARG YARN_VERSION

# ソースリストにPostgreSQLを追加
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -\
  && echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

# ソースリストにNodeJSを追加
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -

# ソースリストにYarnを追加
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -\
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# 依存関係をインストール
# 外部のAptfileを読み込み
COPY .dockerdev/Aptfile /tmp/Aptfile
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends\
    build-essential\
    postgresql-client-$PG_MAJOR\
    nodejs\
    yarn=$YARN_VERSION-1\
    $(cat /tmp/Aptfile | xargs) &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* &&\
    truncate -s 0 /var/log/*log

# bundlerとPATHを設定
ENV LANG=C.UTF-8\
  GEM_HOME=/bundle\
  BUNDLE_JOBS=4\
  BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH\
  BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /app/bin:$BUNDLE_BIN:$PATH

# RubyGemsをアップグレードして必要なバージョンのbundlerをインストール
RUN gem update --system &&\
    gem install bundler:$BUNDLER_VERSION

# appコードを置くディレクトリを作成
RUN mkdir -p /app

WORKDIR /app
```

#### ライブラリのバージョン管理
- ランタイム依存のバージョンはdocker-compose.ymlで指定する
  - `ARG RUBY_VERSION`
  - `ARG PG_MAJOR`
  - `ARG NODE_MAJOR`
  - `ARG YARN_VERSION`
  - `ARG BUNDLER_VERSION`

#### ライブラリのインストール
- Ruby    - ベースイメージ
- PG      - `apt`でインストール
- Node    - `apt`でインストール
- Yarn    - `apt`でインストール
- Bundler - `apt`でインストール

#### 依存関係のインストール
- タスク固有の依存関係をAptfileに切り出す
```
# Aptfile

vim
```
- `DEBIAN_FRONTEND=noninteractive`
  - [answer on Ask Ubuntu](https://askubuntu.com/questions/972516/debian-frontend-environment-variable/972528#972528)
- `--no-install-recommends`
  - 推奨パッケージのインストールを省略し容量を節約する
- `apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && truncate -s 0 /var/log/*log`
  - 取得したパッケージファイルのローカルリポジトリ、インストール中に作成された一時ファイル、ログetcをクリーンアップ

#### BundlerとPATHの設定
- `LANG=C.UTF-8`
  - デフォルトロケールをUTF-8に設定
- `GEM_HOME=/bundle`
  - gemインストールのパスを`/bundle`に設定
  - `docker-compose.yml`で`/bundle`ディレクトリをボリュームとしてマウントする
    - 依存関係を開発環境のホストOSで永続化するため、
- `BUNDLE_PATH` / `BUNDLE_BIN`
  - gemやRuby実行ファイルを探索する場所を指定
- `ENV PATH /app/bin:$BUNDLE_BIN:$PATH`
  - Rubyとアプリケーションバイナリをグローバルに公開
    - `bin/`なしでコマンドを実行できるようにする

## docker-compose.yml
- データベース                   - PostgreSQL
- バックグラウンドジョブアダプタ - Sidekiq
- 単機能のサービスを定義し、実行したいサービスをピンポイントで立ち上げる
  - ex. `$ docker-compose up rails`
```yml
version: '3.4'

services:
  app: &app
    build:
      context: .
      dockerfile: ./.dockerdev/Dockerfile
      args:
        RUBY_VERSION: '2.6.3'
        PG_MAJOR: '11'
        NODE_MAJOR: '11'
        YARN_VERSION: '1.13.0'
        BUNDLER_VERSION: '2.0.2'
    image: example-dev:1.0.0
    tmpfs:
      - /tmp

  backend: &backend
    <<: *app
    stdin_open: true
    tty: true
    volumes:
      - .:/app:cached
      - rails_cache:/app/tmp/cache
      - bundle:/bundle
      - node_modules:/app/node_modules
      - packs:/app/public/packs
      - .dockerdev/.psqlrc:/root/.psqlrc:ro
    environment:
      - NODE_ENV=development
      - RAILS_ENV=${RAILS_ENV:-development}
      - REDIS_URL=redis://redis:6379/
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432
      - BOOTSNAP_CACHE_DIR=/bundle/bootsnap
      - WEBPACKER_DEV_SERVER_HOST=webpacker
      - WEB_CONCURRENCY=1
      - HISTFILE=/app/log/.bash_history
      - PSQL_HISTFILE=/app/log/.psql_history
      - EDITOR=vi
    depends_on:
      - postgres
      - redis

  runner:
    <<: *backend
    command: /bin/bash
    ports:
      - '3000:3000'
      - '3002:3002'

  rails:
    <<: *backend
    command: bundle exec rails server -b 0.0.0.0
    ports:
      - '3000:3000'

  sidekiq:
    <<: *backend
    command: bundle exec sidekiq -C config/sidekiq.yml

  postgres:
    image: postgres:11.1
    volumes:
      - .psqlrc:/root/.psqlrc:ro
      - postgres:/var/lib/postgresql/data
      - ./log:/root/log:cached
    environment:
      - PSQL_HISTFILE=/root/log/.psql_history
    ports:
      - 5432

  redis:
    image: redis:3.2-alpine
    volumes:
      - redis:/data
    ports:
      - 6379

  webpacker:
    <<: *app
    command: ./bin/webpack-dev-server
    ports:
      - '3035:3035'
    volumes:
      - .:/app:cached
      - bundle:/bundle
      - node_modules:/app/node_modules
      - packs:/app/public/packs
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - RAILS_ENV=${RAILS_ENV:-development}
      - WEBPACKER_DEV_SERVER_HOST=0.0.0.0

volumes:
  postgres:
  redis:
  bundle:
  node_modules:
  rails_cache:
  packs:
```

#### `app`
- アプリケーションコンテナの構築に必要な情報を提供する
- `context` - ワーキングディレクトリのパス(Dockerの`build context`)
  - Dockerfileへのパスを明示的に指定
  - `args`でライブラリバージョンを明示的に指定
- `tmpfs` - `/tmp`ディレクトリに対して`tmpfs`マウント
  - 速度の向上のため
  - `tmpfs`マウントされたディレクトリ内のファイルはホストメモリ内にのみ永続化される

#### `backend`
- Rubyサービスで共有する振る舞いの定義
- `volumes:`
  - `.:/app:cached`
    - プロジェクトのルートディレクトリをコンテナ内の`/app`フォルダにマウント
    - ソースファイルは`:cached`でマウント
  - `bundle:/bundle`
    - ホストマシンの`/bundle`の中身を`bundle`という名前のボリュームに保存
    - gemのデータを永続化して複数の実行で使えるようにする
  - `rails_cache:/app/tmp/cache` / `node_modules:/app/node_modules` / `packs:/app/public/packs`
    - 生成されるファイルをDockerボリュームに配置することによりホストマシンのパフォーマンスを向上
  - `.dockerdev/.psqlrc:/root/.psqlrc:ro`
    - コンテナ内部で`$ rails dbconsole`(`$ psql`)する際に必要
    - 前提: コマンド履歴を`log/.psql_history`に保存することで永続化している
    - 前提: 履歴ファイルを環境変数経由で指定できるように`.psqlrc`ファイルを使用している
- `environment:`
  - `X=${X:-smth}`
    - コンテナ内の変数Xについて、ホストマシンに環境変数Xの値があればそれを用い、なければ別の値を用いる
    - `$ docker-compose up`コマンド実行時に別の環境を指定してサービスを実行できるようにしている
  - `DATABASE_URL` / `REDIS_URL` / `WEBPACKER_DEV_SERVER_HOST`
    - アプリケーションを別のサービスに接続するために必要
  - `BOOTSNAP_CACHE_DIR`
    - コンテナ内で`bootsnap`を使用する際に必要
  - `HISTFILE=/app/log/.bash_history`
    - コンテナ内でシェルの操作履歴を残すために必要
  - `EDITOR=vi`
    - コンテナ内のエディタがオープンするような操作を行う際に必要
  - `MALLOC_ARENA_MAX` / `WEB_CONCURRENCY`
    - Railsのメモリハンドリングをチェックしやすくするために必要
- `stdin_open:` / `tty:`
  - サービスをインタラクティブにする
  - `-it`オプションを付けてDockerコンテナを実行するのと同じ

#### `webpacker`
- `WEBPACKER_DEV_SERVER_HOST=0.0.0.0`
  - Webpack dev serverに外部からアクセスできるようにする

#### `runner`
- 【前提】Dockerデーモン起動のための`$ docker-start`スクリプトを用意
```sh
#!/bin/sh

if ! $(docker info > /dev/null 2>&1); then
  echo "Docker for Macを開いています..."
  open -a /Applications/Docker.app
  while ! docker system info > /dev/null 2>&1; do sleep 1; done
  echo "Docker準備OK！"
else
  echo "Dockerは実行中です"
fi
```
- コンテナのシェルにログインするために`$ docker-compose run --rm runner`を実行
