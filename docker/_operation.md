# 操作
1. イメージを取得・コンテナを作成・コンテナを起動
2. 起動中のコンテナを確認
3. ログを確認
4. コンテナを停止
5. コンテナを再起動
6. コンテナを停止
7. 全てのコンテナを確認
8. コンテナを破棄
9. 停止している全コンテナを破棄
10. イメージ一覧を確認
11. イメージを破棄
12. どのコンテナからも利用されていない全イメージを破棄

```
$ docker container run -dit --name web01 -v "$PWD":/usr/local/apache2/htdocs -p 8080:80 httpd:2.4
  # $ docker image     pull   httpd:2.4
  # $ docker container create --name web01 -v "$PWD":/usr/local/apache2/htdocs -p 8080:80 httpd:2.4
  # $ docker container start  web01

$ docker container ls
$ docker container logs  web01
$ docker container stop  web01
$ docker container start web01
$ docker container stop  web01
$ docker container ls    -a
$ docker container rm    web01
$ docker container prune
$ docker image     ls
$ docker image     rm    httpd:2.4
$ docker image     prune
```
- [httpd](https://hub.docker.com/_/httpd)

### コンテナの操作
- 起動・実行コマンドの引数に`/bin/sh` or `/bin/bash`を渡す
  - `-it`オプションを渡さないとシェルを操作できない
  - Ctrl + p -> Ctrl + qでホストに戻り、`$ docker atach NAME`で再度シェルに入る

```
# 起動前のコンテナの操作(runコマンド終了時、シェルとコンテナが終了する)
$ docker run -it --name web01 httpd:2.4 /bin/bash

# 起動中のコンテナの操作(execコマンド終了時、シェルのみが終了する)
$ docker exec -it web01 /bin/bash
```

### ホスト <-> コンテナ間のファイルコピー
- パーミッション・ディレクトリ構造もコピーされる
- コンテナ内に置かれたファイルはコンテナ停止時は削除されないが、コンテナ削除時は削除される

```
# $ docker cp オプション コピー元 コピー先

$ docker cp (host)path/to/filename (container)NAME:path/to/directory
$ docker cp (container)NAME:path/to/filename (host)path/to/directory
```

### ファイルの永続化
#### バインドマウント
- 予めホストに永続化したいファイルを置くためのディレクトリを用意し、コンテナにマウントする
  - バインドマウントはホストから変更できる
  - 設定ファイルの受け渡しをする場合
  - ホストの作業ディレクトリの変更を即座にコンテナから参照する場合

```
$ docker run -dit --name web01 --mount type=bind,src="$PWD",dst=/usr/local/apache2/htdocs -p 8080:80 httpd:2.4
```

#### ボリュームマウント
- 予めDocker Engine上に永続化したいファイルを置くための領域(データボリューム)を確保し、コンテナにマウントする
  - Docker Engineがボリュームを管理するため、物理的な保存場所について意識する必要がなくなる
  - ボリュームマウントはホストから変更できない
  - ボリュームプラグインをインストールすることでAWS S3ストレージなどネットワークストレージを用いることが可能
  - コンテナが扱うデータをブラックボックスとして扱い永続化する場合(DBのデータなど)
1. Docker Engine上にボリュームを作成
2. ボリューム一覧を確認
3. ボリュームをマウントするコンテナを作成
4. コンテナを停止
5. コンテナを削除
6. ボリュームの場所を確認
7. ボリュームを削除
8. 全ボリュームを破棄
```
$ docker volume    create --name mysqlvolume
$ docker volume    ls
$ docker container run --name db01 -dit --mount type=volume,src=mysqlvolume,dst=/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypassword mysql:5.7
$ docker container stop    db01
$ docker container rm      db01
$ docker volume    inspect mysqlvolume
$ docker volume    rm      mysqlvolume
$ docker volume prune
```
- [mysql](https://hub.docker.com/_/mysql)

## オプション
- `-d`
  - デタッチモードで実行
  - コマンドを端末から切り離した状態でバックグラウンドで実行する
  - アタッチモード -> デタッチモード - (`-it`オプション付きで有効化している場合) Ctrl + p -> Ctrl + q
  - デタッチモード -> アタッチモード - `$ docker attach NAME`
- `-i`
  - インタラクティブモードで実行
  - 標準入出力・標準エラー出力をコンテナに連結する
- `-p ホストのポート番号:コンテナのポート番号`
  - ホストのTCPポート番号をコンテナのTCPポート番号にマッピングする
  - `http://ホストのIP:ホストのポート番号`にアクセスするとコンテナのポート番号に転送される
- `--rm`
  - 実行終了時にコンテナを破棄する
- `-t`
  - 疑似端末を有効化
- `-v ホストのディレクトリ:コンテナのディレクトリ` / `--mount type=タイプ,src=マウント元,dst=マウント先`
  - ホストのディレクトリをコンテナのディレクトリにマウントする
- `-w DIRECTORY`
  - コンテナ内のプログラムを実行する際の作業ディレクトリ

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
