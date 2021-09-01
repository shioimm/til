# 操作
1. イメージを取得・コンテナを作成・コンテナを起動
2. 起動中のコンテナを確認
3. ログを確認
4. コンテナを停止
5. コンテナを再起動
6. コンテナを停止
7. 全てのコンテナを確認
8. コンテナを破棄
9. イメージ一覧を確認
10. イメージを破棄

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
$ docker image     ls
$ docker image     rm    REPOSITORY:TAG
```

## オプション
- `-p ホストのポート番号:コンテナのポート番号`
  - ホストのTCPポート番号をコンテナのTCPポート番号にマッピングする
  - `http://ホストのIP:ホストのポート番号`にアクセスするとコンテナのポート番号に転送される
- `-v ホストのディレクトリ:コンテナのディレクトリ`
  - ホストのディレクトリをコンテナのディレクトリにマウントする
- `-d`
  - デタッチモード
  - コマンドを端末から切り離した状態でバックグラウンドで実行する
  - アタッチモード -> デタッチモード - ［Ctrl］＋［P］、［Ctrl］＋［Q］
  - デタッチモード -> アタッチモード - `$ docker attach`
- `-i`
  - インタラクティブモード
  - 標準入出力・標準エラー出力をコンテナに連結する
- `-t`
  - 疑似端末を割り当てる

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
