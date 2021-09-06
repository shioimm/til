# ファイルの永続化
## バインドマウント
- 予めホストに永続化したいファイルを置くためのディレクトリを用意し、コンテナにマウントする
  - バインドマウントはホストから変更できる
  - 設定ファイルの受け渡しをする場合
  - ホストの作業ディレクトリの変更を即座にコンテナから参照する場合

### 手順
```
$ docker run -dit --name web01 --mount type=bind,src="$PWD",dst=/usr/local/apache2/htdocs -p 8080:80 httpd:2.4
```

## ボリュームマウント
- 予めDocker Engine上に永続化したいファイルを置くための領域(データボリューム)を確保し、コンテナにマウントする
  - Docker Engineがボリュームを管理するため、物理的な保存場所について意識する必要がなくなる
  - ボリュームマウントはホストから変更できない
  - ボリュームプラグインをインストールすることでAWS S3ストレージなどネットワークストレージを用いることが可能
  - コンテナが扱うデータをブラックボックスとして扱い永続化する場合(DBのデータなど)

### 手順
1. Docker Engine上にボリュームを作成
2. ボリューム一覧を確認
3. ボリュームをマウントするコンテナを作成
4. コンテナを停止
5. ボリュームの場所を確認
6. ボリュームを使用中のコンテナがないことを確認
7. バックアップ操作を実行
    - バックアップ操作用のbusyboxを`--rm`オプション付きで起動
    - バックアップ対象のボリュームをbusyboxの`/src`にボリュームマウント
    - ホストのカレントディレクトリをbusyboxの`/dest`にバインドマウント
    - tarコマンドを実行
8. ホストにバックアップファイル(backup.tar.gz)が作成されていることを確認
9. ホストでバックアップファイルを確認
10. ボリュームを削除
11. ボリュームを作成
12. ボリュームにバックアップファイルをリストア
13. ボリュームをマウントするコンテナを作成
14. 全ボリュームを破棄

```
$ docker volume    create --name mysqlvolume
$ docker volume    ls
$ docker container run --name db01 -dit --mount type=volume,src=mysqlvolume,dst=/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypassword mysql:5.7
$ docker container stop    db01
$ docker volume    inspect mysqlvolume
$ docker ps -a
$ docker run --rm -v mysqlvolume:/src -v "$PWD":/dest busybox tar czvf /dest/backup.tar.gz -C /src .
# または
$ docker run --rm --volumes-from db01 -v "$PWD":/dest busybox tar czf /dest/backup.tar.gz -C /src .
$ ls -la
$ tar tzvf backup.tar.gz
$ docker volume    rm      mysqlvolume
$ docker volume    create  mysqlvolume2
$ docker run --rm -v mysqlvolume2:/dest -v "$PWD":/src busybox tar xzf /src/backup.tar.gz -C /dest
$ docker container run --name db01 -dit --mount type=volume,src=mysqlvolume2,dst=/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypassword mysql:5.7
$ docker volume prune
```
- [mysql](https://hub.docker.com/_/mysql)

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
