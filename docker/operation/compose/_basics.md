# Docker Compose
- Docker ComposeはDocker Engineの一部ではなくDocker操作の補佐をするPython製のツール
  - Docker Engineとは別にインストールする必要がある
- 操作時点でのdocker-compose.ymlの記述に沿って実行される
  - Docker Composeで起動したコンテナがある状況でdocker-compose.ymlを編集すると
    次会操作時に編集後の内容が適用される

## 操作
#### Docker Composeなし
- WordPress + MySQL
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

#### Docker Composeあり
```yml
# docker-compose.yml

version: "3"

services:
  wordpress-db:
    image: mysql:5.7
    networks:
      - wordpressnet
    volumes:
      - wordpress_db_volume:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: myrootpassword
      MYSQL_DATABASE: wordpressdb
      MYSQL_USER: wordpressuser
      MYSQL_PASSWORD: wordpresspass

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

networks:

  wordpressnet:

volumes:
  wordpress_db_volume:
```

1. コンテナを作成、デタッチモードで起動
2. コンテナ一覧を表示
3. コンテナを停止、破棄
    - デフォルトではボリュームは削除されず、次回`$ docker compose up`時にマウントされる
4. コンテナ一覧を確認
```
$ docker-compose up -d
$ docker-compose ps
$ docker-compose down
$ docker container ps -a
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
