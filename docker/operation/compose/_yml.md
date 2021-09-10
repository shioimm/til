# docker-compose.yml
- `version:` - バージョン設定
- `services:` - 全体を構成する一つ一つのコンテナ
- `networks:` - サービスが参加するネットワーク
- `volumes:` - サービスが利用するボリューム

### `version:`
```yml
version: "3"
```

### `services:`
```yml
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
```

### `networks:`
```yml
networks:

  wordpressnet:
```

### `volumes:`
```yml
volumes:
  wordpress_db_volume:
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
