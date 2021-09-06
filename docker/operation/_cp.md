# ホスト <-> コンテナ間のファイルコピー
- パーミッション・ディレクトリ構造もコピーされる
- コンテナ内に置かれたファイルはコンテナ停止時は削除されないが、コンテナ削除時は削除される

```
# $ docker cp オプション コピー元 コピー先

$ docker cp (host)path/to/filename (container)NAME:path/to/directory
$ docker cp (container)NAME:path/to/filename (host)path/to/directory
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
