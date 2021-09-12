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
- `$ docker container run`

```yml
services:
  wordpress-db:
    image: mysql:5.7 # mysqlイメージを利用
    networks:
      - wordpressnet # wordpressnetネットワークに接続
    volumes:
      # Docker Engine上のwordpress_db_volumeボリュームをwordpress-dbコンテナの/var/lib/mysqlにマウント
      - wordpress_db_volume:/var/lib/mysql
    restart: always  # 起動失敗時は常に再起動する
    environment: # wordpress-dbコンテナが利用する環境変数
      MYSQL_ROOT_PASSWORD: myrootpassword
      MYSQL_DATABASE: wordpressdb
      MYSQL_USER: wordpressuser
      MYSQL_PASSWORD: wordpresspass

  wordpress-app:
    depends_on:
      - wordpress-db # wordpress-dbコンテナ起動後に実行
    image: wordpress # wordpressイメージを利用
    networks:
      - wordpressnet # wordpressnetネットワークに接続
    ports:
      - 8080:80 # ホスト8080番ポートをwordpress-appコンテナ80番ポートにマッピング
    restart: always # 起動失敗時は常に再起動する
    environment: # wordpress-appコンテナが利用する環境変数
      WORDPRESS_DB_HOST: wordpress-db
      WORDPRESS_DB_NAME: wordpressdb
      WORDPRESS_DB_USER: wordpressuser
      WORDPRESS_DB_PASSWORD: wordpresspass
```

### `networks:`
- `$ docker network create↲`
- 明示的にネットワークを指定しなかった場合、新しいネットワークを自動的に作成し、
  docker-compose.ymlに定義した全てのサービスを当該ネットワークに接続するように構成する

```yml
networks:

  wordpressnet:
```

### `volumes:`
- `$ docker volume create`

```yml
volumes:
  wordpress_db_volume:
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
