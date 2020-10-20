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
