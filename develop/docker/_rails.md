# Quic Start
- 参照: [クィックスタート: Compose と Rails](https://docs.docker.jp/compose/rails.html)

## 1. プロジェクトの定義
- Docker用設定ファイルの追加
  - Dockerfile         - Dockerイメージ生成のための設定を記述
  - docker-compose.yml - すべてのサービスの取りまとめを記述
- Rails用初期化ファイルの追加(`$ rails new`で置き換えられる)
  - 初期化用Gemfile
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
