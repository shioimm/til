# コマンド
### イメージをビルド
- 作成するイメージ名・タグ名、Dockerfileを置いてあるディレクトリを指定する
```
$ docker build -t イメージ名:タグ名 /path/to/Dockerfileを置いてあるディレクトリ

# 作成したイメージを確認
$ docker image ls イメージ名:タグ名
```

### コンテナの実行
- 作成するコンテナ名、コンテナの元になるイメージ名・タグ名を指定する
```
$ docker run --name コンテナ名 イメージ名:タグ名
```

### コンテナの中でシェルをインタラクティブに操作する
```
$ docker run -it --name コンテナ名 /bin/bash
```

### コンテナからネットワークに接続する
```
$ docker run -p localhostのポート番号:コンテナのポート番号 --name コンテナ名

# デーモン化
$ docker run -d -p localhostのポート番号:コンテナのポート番号 --name コンテナ名
```

### コンテナの停止・削除
```
$ docker stop コンテナ名

$ docker rm コンテナ名

# 停止中のコンテナと無名のイメージを削除
$ docker system prune
```

### イメージの削除
```
$ docker rmi イメージ名
```

### DockerHubからイメージをpull、push
```
$ docker login

$ docker pull イメージ名:タグ名

$ docker push イメージ名:タグ名
```

### イメージに対する変更履歴を確認
```
$ docker history イメージ名
```

### 起動中のコンテナプロセス一覧を表示
```
$ docker ps

# 停止中のコンテナプロセスも表示
$ docker ps -a
```

### コンテナのログを表示
```
$ docker logs コンテナ名
```

## docker-compose
- 複数のDockerコンテナを同時に立ち上げることができる

### docker-compose.ymlからイメージをビルド
```
$ docker-compose build
```

### docker-compose.ymlで定義したサービスの開始
- `-d`オプションでデーモン化
```
$ docker-compose up
```

### docker-compose.ymlで定義したサービスを指定し、タスクをアドホックに実行
```
$ docker-compose run サービス名 実行したいタスク・コマンド
```

### docker-composeで立ち上げた環境を(DBに保存されたデータごと)削除
```
$ docker-compose down
```

### docker-composeのログを出力
```
$ docker-compose logs
```

## 参照
- [コマンドライン・リファレンス](https://docs.docker.jp/compose/reference/toc.html)
- [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その2:Dockerってなに？ 〜](https://tech-lab.sios.jp/archives/19073)
