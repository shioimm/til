# docker-compose
## TL;DR
- 複数のコンテナからなる一つのシステムの構築を簡便に行うためのツール
  - 設定 - `docker-compose.yml`の記述
  - 起動 - `$ docker-compose up` `-d`でデーモン化
  - 終了 - `$ docker-compose stop`

## Get Started
- [Docker Compose のインストール](https://docs.docker.jp/compose/install.html)

## `docker-compose.yml`
```yml
# 例

version: '3'                         # docker-compose.ymlのファイルフォーマットバージョン

services:                            # コンテナを管理する単位
   httpd:                            # コンテナ名
     image: httpd:2.4.43             # Dockerリポジトリからpullするイメージ
     volumes:                        # ホスト上にボリュームを定義
      - /home/xxx/html:/var/www/html # httpdコンテナの/var/www/htmlをホスト上の/home/xxx/htmlにマウント
     ports:                          # ポート番号の設定
       - "80:80"                     # localhost:80への通信をコンテナ:80に転送
```

### `Dockerfile`との併用
- `Dockerfile`を`docker-compose.yml`内でコンテキストとして利用することもできる
```
# 例: Dockerfile

FROM httpd:2.4.43

RUN apt-get update && apt-get -y install wget
```

```yml
# 例: docker-compose.yml

version: '3'

services:
  httpd:
    build:
      context: . # カレントディレクトリ内のDockerfileコンテキストの利用
    ports:
      - "80:80"
```

### 複数コンテナの起動
```yml
# 例

version: '3'

services:
   mysql:                            # コンテナ名
     image: mysql:8.0.20             # コンテナを管理する単位
     restart: always                 # ホストOS/Dockerデーモン起動時に自動的にコンテナを起動
     environment:                    # 環境変数の設定
       MYSQL_ROOT_PASSWORD: xxxxx
       MYSQL_DATABASE: xxxxx
       MYSQL_USER: xxxxx
       MYSQL_PASSWORD: xxxxx

   wordpress:                        # コンテナ名
     depends_on:                     # 起動順序の制御
       - mysql                       # mysqlの起動後にwordpressを起動
     image: wordpress:php7.4-apache  # コンテナを管理する単位
     ports:                          # ポート番号の設定
       - "80:80"                     # localhost:80への通信をコンテナ:80に転送
     restart: always                 # ホストOS/Dockerデーモン起動時に自動的にコンテナを起動
     environment:                    # 環境変数の設定
       WORDPRESS_DB_HOST: mysql:3306 # docker-conpose.ymlで定義したサービス名(mysql)でアクセス可能
       WORDPRESS_DB_USER: yyyyy
       WORDPRESS_DB_PASSWORD: yyyyy

volumes:                             # ホスト上にボリュームを定義
  db_data: /var/lib/mysql            # mysqlコンテナの/var/lib/mysqlをホスト上のdb_dataにマウント
```

## 引用・参照
- [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その4:docker-composeってなに？ 〜](https://tech-lab.sios.jp/archives/20051)
