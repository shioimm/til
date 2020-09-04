# コマンド
- [コマンドライン・リファレンス](https://docs.docker.jp/compose/reference/toc.html)

### DockerイメージをDockerレジストリからダウンロード
```
$ docker login # username / password
$ docker pull [オプション] [サービス...]
```

### Dockerイメージに対する変更履歴を確認
```
$ docker history [オプション] イメージ
```

### Dockerイメージをビルド
```
$ docker build [ -t ｛イメージ名｝ [ :{タグ名} ] ] {Dockerfileのあるディレクトリ}
```

### Dockerコンテナを起動
```
$ docker run [オプション] [--name {コンテナー名}] {イメージ名}[:{タグ名}] [コンテナーで実行するコマンド] [引数]
```

### docker-composeを立ち上げる
- `-d`オプションでデーモン化
```
$ docker-compose up [オプション] [サービス...]
```

### docker-composeでコマンドを実行
```
$ docker-compose run [-f=<引数>...] [オプション] [コマンド] [引数...]
```

### docker-composeで立ち上げた環境を(DBに保存されたデータごと)捨てる
```
$ docker-compose down [オプション]
```
