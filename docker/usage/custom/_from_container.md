# コンテナからカスタムイメージを作る
- ベースとなるイメージからコンテナを起動し、そのコンテナに対して変更を加えた後
  `$ docker commit`コマンドを利用してイメージ化する

#### 用途
- コンテナのアーカイブ

## コンテナのイメージ化
1. 新しいコンテナを起動
2. ローカルのファイルをコンテナ内へコピー
3. コンテナからイメージを生成

```
$ docker run -dit --name webcontent -p 8080:80 httpd:2.4
$ docker cp /tmp/index.html webcontent:/usr/local/apache2/htdocs
$ docker commit  webcontent mycustomed_httpd
$ docker image ls
```

```
$ cat /tmp/index.html
<html>
  <body>
    <div>Docker Content</div>
  </body>
</html>
```

## イメージへの操作ログを表示

```
$ docker history mycustomed_httpd
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
