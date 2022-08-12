# Docker Compose
- e.g. WordPress + MySQL

## インストール

```
$ sudo apt install -y python3 python3-pip
$ sudo pip3 install docker-compose
$ docker compose --version
```

## docker-compose.yml
- services (コンテナ)、networks (コンテナが参加するネットワーク)、volumes (ボリューム) を定義する

```yml
version: "3"

services:
  wordpress-db: # DBコンテナの定義
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

  wordpress-app: # アプリケーションコンテナの定義
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

networks:

  wordpressnet:

volumes:
  wordpress_db_volume:
```

## コンテナを作成・起動
- 通常はデタッチモードで起動する

```
$ docker-compose up -d
$ docker-compose ps
```

- コンテナ・ネットワーク・ボリュームが作成され、コンテナが起動する
- コンテナ名は`作業用ディレクトリ_コンテナ名_N`として命名される

## コンテナの停止・削除
- コンテナ・ネットワークは削除される
- ボリュームは削除されず (デフォルト) 、次回`$ docker-compose up`時にマウントされる

```
$ docker-compose down
$ docker-compose psa
```

## 特定のコンテナの操作
- docker-compose(1)コマンドの操作にはdocker-compose.ymlが必要
- docker-compose(1)コマンドでは操作するコンテナのservice名を指定する
- docker-compose(1)コマンドではコンテナの依存関係が考慮される
1. 特定のコンテナをインタラクティブモードで操作
2. 特定のコンテナを停止
3. 特定のコンテナを再起動

```
$ docker-compose exec wordpress-app /bin/bash
root@xxxxxxxxxxxx:/var/www/html# exit
$ docker-compose stop wordpress-db
$ docker-compose start wordpress-db
```

#### Docker Composeを使用しない場合の操作

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
