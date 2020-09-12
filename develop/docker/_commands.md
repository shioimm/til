# コマンド
- [コマンドライン・リファレンス](https://docs.docker.jp/compose/reference/toc.html)

### DockerHubからDockerイメージをダウンロード
```
$ docker login

$ docker pull [オプション] [サービス...]
```

### Dockerイメージに対する変更履歴を確認
```
$ docker history [オプション] イメージ
```

### Dockerfileから新しいDockerイメージを構築
```
$ docker build [ -t ｛イメージ名｝ [ :{タグ名} ] ] {Dockerfileのあるディレクトリ}
```

### Dockerコンテナを起動
```
$ docker run [オプション] [--name {コンテナー名}] {イメージ名}[:{タグ名}] [コンテナーで実行するコマンド] [引数]

# ホストマシンからDockerコンテナにVolumeをマウント
$ docker run --volumes マウント元パス(ホスト):マウント先パス コンテナ

# Dockerコンテナの環境変数を設定する
$ docker run -d --env KEY=VALUE コンテナ
```
- `--detach` - バックグラウンドで起動

### Dockerコンテナを停止
```
$ docker stop [オプション] コンテナ [コンテナ...]
```

### 起動中のDockerコンテナプロセス一覧を表示
```
$ docker ps

# 停止中のコンテナプロセスも表示
$ docker ps -a
```

### Dockerコンテナのログを表示
```
$ docker logs [オプション] コンテナ
```

### Dockerコンテナのメタ情報を表示
```
$ docker inspect [オプション] コンテナ|イメージ|タスク [コンテナ|イメージ|タスク...]
```

### 実行中のDockerコンテナの中に入る
```
$ docker exec [オプション] コンテナ コマンド [引数...]
$ docker exec -it コンテナ bash # bashで入り操作を標準入出力で表示する
```

### Dockerコンテナを元に新しいDockerイメージを生成
```
$ docker commit [オプション] コンテナ [リポジトリ[:タグ]]
```

### 生成したDockerイメージをDockerHubに保存
```
# 生成したDockerイメージにタグ付け
$ docker tag ユーザー名/リポジトリ名(イメージ名)

# ログイン
$ docker login

# DockerイメージをDockerHubに送信
$ docker push [オプション] 名前[:タグ]
```

### 取得済みのDockerイメージ一覧
```
$ docker images [オプション] [リポジトリ[:タグ]]
```

### Dockerコンテナ・Dockerイメージの削除
```
# 停止中のコンテナと無名のイメージを削除
$ docker system prune

# コンテナを削除
$ docker rm [オプション] コンテナ [コンテナ...]

# 停止中の全コンテナを削除
$ docker rm $(docker ps -a -q)

# 起動中のコンテナを含む全コンテナを削除
$ docker rm -vf $(docker ps -a -q)

# イメージを削除
$ docker rmi [オプション] イメージ [イメージ...]

# 起動中のコンテナを含む全イメージを削除
$ docker rmi -f $(docker ps -a -q)
```

## docker-compose
- Dockerコンテナ起動時の設定をyamlファイルに記述
- 複数のDockerコンテナを同時に立ち上げることができる

### docker-composeを立ち上げる
- `-d`オプションでデーモン化
```
$ docker-compose up [オプション] [サービス...]
```

### docker-composeでコマンドを実行
```
$ docker-compose run [-f=<引数>...] [オプション] [コマンド] [引数...]
```

### docker-composeで立ち上げた環境を(DBに保存されたデータごと)削除
```
$ docker-compose down [オプション]
```

### docker-composeのログを出力
```
$ docker-compose logs [オプション] [サービス...]
```
