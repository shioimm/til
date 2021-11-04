1.ファイルをリモートホストへコピーする
```
$ scp server/Dockerfile.rb USERNAME@IPアドレス:/path/to/dir
$ scp server/server.rb USERNAME@IPアドレス:/path/to/dir
```

2.リモートホストでDockerイメージをビルド

```
$ cd /path/to/dir
$ docker build -t drb/kvs .
```

3.リモートホストでDockerを実行
```
$ docker run --rm -it -p 8080:8080 drb/kvs
```

4.ローカルホストでクライアントプログラムを実行
```
$ ruby client/client.rb druby://リモートホストのパブリックIPアドレス:8080
```
