# 操作
1. イメージをpull
2. コンテナを起動
3. 起動中のコンテナを確認
4. ログの確認
5. コンテナを停止
6. コンテナを再起動
7. コンテナを停止
8. 全てのコンテナを確認
8. コンテナの破棄
9. イメージ一覧を確認
10. イメージの破棄

```
$ docker pull            REPOSITORY:TAG
$ docker container run   REPOSITORY:TAG --name NAME その他オプション
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
