# Docker Compose
- Docker ComposeはDocker Engineの一部ではなくDocker操作の補佐をするPython製のツール
  - Docker Engineとは別にインストールする必要がある

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
```
# docker-compose.yml

version: "3"

services:
  wordpress-db:
    image: mysql:5.7
    networks:
      - wordpressnet
    volumes:
      - wordpress_db_volume:/ver/lib/mysql
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
      WORDPRESS_DB_NAME: wordpress-db
      WORDPRESS_DB_USER: wordpressuser
      WORDPRESS_DB_PASSWORD: wordpresspass

networks:
  wordpressnet:

volumes:
  wordpress_db_volume:
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
