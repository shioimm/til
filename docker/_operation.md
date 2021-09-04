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
$ docker container run REPOSITORY:TAG --name NAME その他オプション
  # $ docker image     pull   REPOSITORY:TAG
  # $ docker container create --name NAME その他オプション
  # $ docker container start  --name NAME

$ docker container ls
$ docker container logs  NAME
$ docker container stop  NAME
$ docker container start NAME
$ docker container stop  NAME
$ docker container ls    -a
$ docker container rm    NAME
$ docker container prune
$ docker image     ls
$ docker image     rm    REPOSITORY:TAG
$ docker image     prune
```

### コンテナの操作
- 起動・実行コマンドの引数に`/bin/sh` or `/bin/bash`を渡す
  - `-it`オプションを渡さないとシェルを操作できない
  - Ctrl + p -> Ctrl + qでホストに戻り、`$ docker atach NAME`で再度シェルに入る

```
# 起動前のコンテナの操作(runコマンド終了時、シェルとコンテナが終了する)
$ docker run -it --name NAME その他のオプション /bin/bash

# 起動中のコンテナの操作(execコマンド終了時、シェルのみが終了する)
$ docker exec -it NAME /bin/bash
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
$ docker run -dit --name NAME -v (host)path/to/directory:(container)path/to/directory -p 8080:80 httpd:2.4
```

#### ボリュームマウント
- 予めDocker Engine上に永続化したいファイルを置くための領域(データボリューム)を確保し、コンテナにマウントする
  - Docker Engineがボリュームを管理するため、物理的な保存場所について意識する必要がなくなる
  - ボリュームマウントはホストから変更できない
  - ボリュームプラグインをインストールすることでAWS S3ストレージなどネットワークストレージを用いることが可能
  - コンテナが扱うデータをブラックボックスとして扱い永続化する場合(DBのデータなど)
1. Docker Engine上にボリュームを作成
2. ボリュームを削除
3. ボリューム一覧を確認
4. 全ボリュームを破棄
```
$ docker volume create
$ docker volume ls
$ docker volume rm
$ docker volume prune
```

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
- `-v ホストのディレクトリ:コンテナのディレクトリ`
  - ホストのディレクトリをコンテナのディレクトリにマウントする
- `-w DIRECTORY`
  - コンテナ内のプログラムを実行する際の作業ディレクトリ

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
