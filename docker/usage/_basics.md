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
