# バインドマウント
- ホストのディレクトリをコンテナにマウントする
  - ホストがディレクトリを管理する

#### 用途
- 設定ファイルの受け渡しをする場合
- ホストの作業ディレクトリの変更を即座にコンテナから参照する場合

## ボリュームのマウント
```
# -v /ホストのディレクトリへのパス:コンテナのディレクトリへのパス

$ docker run -dit --name web01 -v /home/ubuntu/web01data/:/usr/local/apache2/htdocs -p 8080:80 httpd:2.4
```
- マウント元のパスを`/`から指定する (指定しない場合ボリュームマウントになる)

#### mountオプションの利用によるボリュームのマウント (推奨)
```
--mount type=マウントの種類,src=マウント元,dst=マウント先
```

```
$ docker run -dit --name web01 --mount type=bind,src="$PWD",dst=/usr/local/apache2/htdocs -p 8080:80 httpd:2.4
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
