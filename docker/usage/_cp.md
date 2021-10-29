# ホスト <-> コンテナ間のファイルコピー
- パーミッション・ディレクトリ構造もコピーされる
- コンテナ内に置かれたファイルはコンテナ停止時は削除されないが、コンテナ削除時は削除される

```
# ホスト -> コンテナ
# $ docker cp コピー元のパス名 コンテナ名(コンテナID):コピー先のパス名

$ docker cp /tmp/index.html my-apache-container:/usr/local/apache2/htdocs/
```

```
# コンテナ -> ホスト
# $ docker cp コンテナ名(コンテナID):コピー元のパス名 コピー先のパス名

$ docker cp my-apache-container:/usr/local/apache2/htdocs/index.html /tmp/
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
