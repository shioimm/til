# Docker Compose
- e.g. WordPress + MySQL

### インストール

```
$ sudo apt install -y python3 python3-pip
$ sudo pip3 install docker-compose
$ docker compose --version
```

### docker-compose.yml
- services (コンテナ)、networks (コンテナが参加するネットワーク)、volumes (ボリューム) を定義する

```yml
version: "3"

# コンテナの定義
services:
  # DBコンテナの定義
  wordpress-db:
    image: mysql:5.7
    networks:
      - wordpressnet
    volumes:
      - type: volume
      - source: wordpress_db_volume
      - target: /var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: myrootpassword
      MYSQL_DATABASE: wordpressdb
      MYSQL_USER: wordpressuser
      MYSQL_PASSWORD: wordpresspass

  # アプリケーションコンテナの定義
  wordpress-app:
    depends_on:
      - wordpress-db
    image: wordpress
    networks:
      - wordpressnet
    ports:
      - 8080:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: wordpress-db
      WORDPRESS_DB_NAME: wordpressdb
      WORDPRESS_DB_USER: wordpressuser
      WORDPRESS_DB_PASSWORD: wordpresspass

# ネットワークの定義 (明示しない場合は新規作成される)
networks:
  wordpressnet:

# ボリュームの定義
volumes:
  wordpress_db_volume:
```

### イメージの作成

```
$ docker-compose build
```

### コンテナを作成・起動
- docker-compose.ymlファイルを置いたディレクトリ内で操作する
- 通常はデタッチモードで起動する

```
$ docker-compose up -d
```

- イメージが存在しない場合は併せて作成
- コンテナ・ネットワーク・ボリュームが作成され、コンテナが起動する
- コンテナ名は`作業用ディレクトリ_コンテナ名_N`として命名される

### コンテナの確認
1. コンテナ一覧を表示
2. Composeファイルの確認
3. コンテナの出力を表示

```
$ docker-compose ps
$ docker-compose config
$ docker-compose logs
```

### コンテナの停止・削除
- コンテナ・ネットワークは削除される
- ボリュームは削除されず (デフォルト) 、次回`$ docker-compose up`時にマウントされる

```
$ docker-compose down
$ docker-compose ps -a
```

### 既存のコンテナを起動

```
$ docker-compose start
```

### 特定のコンテナの操作
1. 特定のコンテナのシェルを実行
2. 特定のコンテナを停止
3. 特定のコンテナを再起動

```
$ docker-compose exec wordpress-app /bin/bash
root@xxxxxxxxxxxx:/var/www/html# exit
$ docker-compose stop wordpress-db
$ docker-compose start wordpress-db
```

#### dockerコマンドとの違い
- docker-composeコマンドの操作にはdocker-compose.ymlが必要
- docker-composeコマンドでは操作するコンテナのservice名を指定する
- docker-composeコマンドではコンテナの依存関係が考慮される

### Docker Composeを使用しない場合の操作

```
$ docker network create wordpressnet
$ docker volume create wordpress_db_volume
$ docker run --name wordpress-db -dit -v wordpress_db_volume:/var/lib/mysql \
> -e MYSQL_ROOT_PASSWORD=myrootpassword -e MYSQL_DATABASE=wordpressdb \
> -e MYSQL_USER=wordpressuser -e MYSQL_PASSWORD=wordpresspass \
> --net wordpressnet mysql:5.7
$ docker run --name wordpress-app -dit -p 8080:80 \
> -e WORDPRESS_DB_HOST=wordpress-db -e WORDPRESS_DB_NAME=wordpressdb \
> -e WORDPRESS_DB_USER=wordpressuser -e WORDPRESS_DB_PASSWORD=wordpresspass \
> --net wordpressnet wordpress

$ docker stop wordpress-db wordpress-app
$ docker rm wordpress-db wordpress-app
$ docker network rm wordpressnet
$ docker volume rm wordpress_db_volume
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
