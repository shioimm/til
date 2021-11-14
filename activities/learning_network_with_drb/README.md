# 実行方法
1. ホストマシンにそれぞれ環境変数`LOCAL_HOST_ADDRESS` / `REMOTE_HOST_ADDRESS`を設定
2. ping(ping6)で疎通確認
3. プログラムを実行 (`$ ruby server/server.rb` -> `$ ruby client/client.rb`)

### Dockerfileを使う場合
1.ホストマシンにそれぞれ環境変数`LOCAL_HOST_ADDRESS` / `REMOTE_HOST_ADDRESS`を設定

2.サーバー側・クライアント側でそれぞれDockerイメージをビルド
```
$ cd /path/to/server
$ docker build -t drb/server .
```

```
$ cd /path/to/client
$ docker build -t drb/client .
```

3.サーバー側・クライアント側でそれぞれDockerを実行 (環境変数を渡す / サーバー -> クライアント)
```
$ docker run --rm -it -e LOCAL_HOST_ADDRESS= -e REMOTE_HOST_ADDRESS= -p 8080:8080 drb/server
```

```
$ docker run --rm -it -e LOCAL_HOST_ADDRESS= -e REMOTE_HOST_ADDRESS= -p 8080:8080 drb/client
```
