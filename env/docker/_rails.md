# Quic Start
## 1. 設定ファイルの用意
#### Dockerfile
```
FROM ruby:3.0.0-slim-buster

RUN apt-get update -qq && apt-get install -y \
    curl \
    libpq-dev \
    build-essential \
    postgresql-client

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y \
    nodejs yarn

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

COPY package.json /myapp/package.json
COPY yarn.lock /myapp/yarn.lock
RUN yarn install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
```

#### Gemfile
- `$ rails new`時に置き換えられる

```
source 'https://rubygems.org'
gem 'rails', '~>6.1'
```

#### Gemfile.lock
- 空のままにしておく
- `$ rails new`時に置き換えられる

#### entrypoint.sh
```
#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
```

#### docker-compose.yml
```
version: '3'
services:
  db:
    image: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres:/var/lib/postgresql/data:cached
    environment:
      PGDATA: /var/lib/postgresql/data/pgdata
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      TZ: Asia/Tokyo
  web:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/myapp
    ports:
      - "3000:3000"
    environment:
      RAILS_ENV: development
      NODE_ENV: development
      DATABASE_HOST: db
      DATABASE_PORT: 5432
      DATABASE_USER: postgres
      DATABASE_PASSWORD: password
    depends_on:
      - db

volumes:
  postgres:
```

#### .dockerigore
- ホストには存在しているがDockerイメージには組み込みたくないファイル群
- `.git` / `vendor/bundle` / `log/` / `tmp/`

## 2. Railsアプリケーションの構築
- ComposeがDockerfileを使用してアプリケーションのイメージをビルドする
  - ビルドされたイメージを使用して生成されたコンテナ内で`$ rails new`が実行される
  - プロジェクトディレクトリはコンテナにマウントされる

```
$ docker-compose run web rails new . --force --database=postgresql
```

## 3. Dockerイメージの構築
- `$ rails new`で置き換えられたGemfileを元にDockerイメージを構築する

```
$ docker-compose build
```

## 4. 環境変数の設定
#### Gemfile
```
gem 'dotenv-rails'
```

#### .gitignore
```
.env
```

#### .env
```
MYAPP_DATABASE_HOST=任意のホスト名
MYAPP_DATABASE_USERNAME=任意のユーザー名
MYAPP_DATABASE_PASSWORD=任意のパスワード
```
- `""`で囲むとdocker-compose.ymlが正しくパースしない

## 4. データベースの接続設定
#### docker-compose.ymlの修正
```yml
  # ...

  db:
    image: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres:/var/lib/postgresql/data:cached
    environment:
      PGDATA: /var/lib/postgresql/data/pgdata
      POSTGRES_USER: ${MYAPP_DATABASE_USERNAME}
      POSTGRES_PASSWORD: ${MYAPP_DATABASE_PASSWORD}
      TZ: Asia/Tokyo

  # ...
```

#### config/database.yml
```
default: &default
  adapter: postgresql
  encoding: unicode
  host: <%= ENV.fetch('MYAPP_DATABASE_HOST') { 'db' } %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development
  username: <%= ENV.fetch('MYAPP_DATABASE_USERNAME') { 'postgres' } %>
  password: <%= ENV.fetch('MYAPP_DATABASE_PASSWORD') { 'password' } %>

test:
  <<: *default
  database: myapp_test
  username: <%= ENV.fetch('MYAPP_DATABASE_USERNAME') { 'postgres' } %>
  password: <%= ENV.fetch('MYAPP_DATABASE_PASSWORD') { 'password' } %>

production:
  <<: *default
  database: myapp_production
  username: myapp
  password: <%= ENV['MYAPP_DATABASE_PASSWORD'] %>
```

#### DB設定
```
$ docker-compose exec db bash

# パスワード設定
root@container-id:/# passwd postgres
New password: # 任意のパスワード
Retype new password: # 任意のパスワード
passwd: password updated successfully
```

#### DBの作成
```
$ docker-compose down
$ docker-compose up -d
$ docker-compose run web rake db:create
```

#### `error: password authentication failed for user "xxx"`
- db volumeを削除する
  - [Password does not match for user “postgres”](https://stackoverflow.com/questions/54764965/password-does-not-match-for-user-postgres)
```
$ docker volume ls
$ docker volume prune
```

## 4. Rails の「ようこそ」ページの確認
- 指定したローカルホストにてアプリケーションの起動を確認できる

## 5. アプリケーションの停止
- Composeの停止 `$ docker-compose down`

## 6. アプリケーションの再起動
1. `$ docker-compose up`
2. `$ docker-compose run web rake db:create`

## 参照
- [クィックスタート: Compose と Rails](https://docs.docker.jp/compose/rails.html)
