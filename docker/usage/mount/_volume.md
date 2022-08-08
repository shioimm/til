# ボリュームマウント
- ホストのDocker Engine上に確保した領域 (ボリューム) をコンテナにマウントする
  - Docker Engineがボリュームを管理する
    - 物理的な保存場所について意識する必要がなくなる
    - ホストから変更不可能
  - ボリュームプラグインをインストールすることによって
    外部のネットワークストレージ (e.g. AWS S3、NFS) を用いることが可能

#### 用途
- コンテナが扱うデータをブラックボックスとして扱い、
  コンテナを破棄してもデータが残るようにしたいだけの場合 (DBのデータなど)
- 設定ファイルの受け渡しや作業ディレクトリの変更を即座にコンテナから参照したい場合はバインドマウントを使う

## ボリュームの作成
1. Docker Engine上にボリュームを作成
2. ボリューム一覧を確認

```
$ docker volume create --name mysqlvolume
$ docker volume ls
```

## ボリュームのマウント・DB操作・動作確認
1. ボリュームをマウントするコンテナを作成 (ボリューム名:ホストのディレクトリ)
2. コンテナ内に入る
3. DB操作
4. コンテナから抜ける
5. コンテナを停止・破棄
6. ボリュームをマウントするい新しいコンテナを作成
7. コンテナ内に入る
8. DB操作 -> マウントしたボリューム上のDBに格納されたレコードが存在することを確認

```
$ docker run --name db01 -dit -v mysqlvolume:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypassword mysql:5.7
$ docker exec -it db01 /bin/bash

/# mysql -p # パスワードmypasswordを入力

mysql> CREATE DATABASE exampledb;
mysql> use exampledb;
mysql> CREATE TABLE exampletable (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(50), PRIMARY KEY(id));
mysql> INSERT INTO exampletable (name) VALUES ('user01');
mysql> SELECT * FROM exampletable; # 挿入したレコード一覧が表示される
mysql> \q

/# exit

$ docker stop db01; docker rm db01
$ docker run --name db01 -dit -e MYSQL_ROOT_PASSWORD=mypassword mysql:5.7
$ docker exec -it db01 /bin/bash

/# mysql -p # パスワードを入力

mysql> use exampledb;
mysql> SELECT * FROM exampletable; # 挿入したレコード一覧が表示される
```

#### mountオプションの利用によるボリュームマウント (推奨)
```
--mount type=マウントの種類,src=マウント元,dst=マウント先
```

```
$ docker container run --name db01 -dit --mount type=volume,src=mysqlvolume,dst=/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypassword mysql:5.7
```

## ボリュームの場所を確認

```
$ docker volume inspect mysqlvolume
[
    {
        "CreatedAt": "2021-10-30T06:00:14Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/mysqlvolume/_data", # /var/lib/docker/volumes/以下にある
        "Name": "mysqlvolume",
        "Options": {},
        "Scope": "local"
    }
]
```

## データのバックアップ

```
# バックアップ
ホスト上にバックアップ用のLinuxコンテナを用意
  -> Linuxコンテナにバックアップ対象のボリュームをマウントして起動
  -> Linuxコンテナでtarコマンドを実行し、ホスト上にアーカイブファイルを作成

# リストア
Docker Engine上にボリュームを作成
  -> Linuxコンテナでtarコマンドを実行し、ボリュームにアーカイブを展開する
```

#### バックアップ
1. 軽量Linuxシステムのbusyboxを起動し、`tar(1)`コマンドでバックアップを作成
2. ホストのカレントディレクトリにバックアップファイルが作成されていることを確認

```
# ボリュームをマウントしたコンテナを予め停止しておく
$ docker run --rm -v mysqlvolume:/src -v "$PWD":/dest busybox tar czvf /dest/backup.tar.gz -C /src .
$ ls -la # backup.tar.gzファイルが作成されている
```

- `-v mysqlvolume:/src`
  - バックアップ対象 (mysqlvolume) をbusyboxの`/src`にボリュームマウント
- `-v "$PWD":/dest`
  - ホストのカレントディレクトリをbusyboxの`/dest`にバインドマウント
- `tar czvf /dest/backup.tar.gz -C /src .`
  - busyboxの`/src`以下の全ファイルを`/dest/backup.tar.gz`にバックアップ

#### volumes-fromオプションの利用によるマウント情報の引き継ぎ
1. ボリュームをマウントするコンテナを作成
2. コンテナを停止・削除
3. 1のコンテナと同じマウント情報でバックアップを作成
```
$ docker run --name db01 -dit -v mysqlvolume:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypassword mysql:5.7
$ docker stop db01; docker rm db01
$ docker run --rm --volumes-from db01 -v "$PWD":/dest busybox tar czvf /dest/backup.tar.gz -C /var/lib/mysql .
```

#### データのリストア
1. ボリュームの作成
2. 軽量Linuxシステムのbusyboxを起動し、`tar(1)`コマンドでデータをリストア

```
$ docker volume create mysqlvolume
$ docker run --rm -v mysqlvolume:/dest -v "$PWD":/src busybox tar xzf /src/backup.tar.gz -C /dest
```

## 停止している全ボリュームの削除

```
$ docker volume prune
```

- [mysql](https://hub.docker.com/_/mysql)

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
