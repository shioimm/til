# Dockerfile
- 参照: [Dockerfile リファレンス](https://docs.docker.jp/engine/reference/builder.html)
- 参照: [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その3:Dockerfileってなに？ 〜](https://tech-lab.sios.jp/archives/19191)

## TL;DR
- 新しいDockerイメージを構築する際に実行するコマンドをコード化したファイル

## USAGE
```
FROM    イメージ名:タグ名       # ベースとするDockerイメージ

WORKDIR /path/to/workdir        # ワークディレクトリ

COPY    ファイル名 /path/to/dir # ホストからコンテナへコピーするファイル

RUN     シェルコマンド名        # docker build時に実行するシェルコマンド

ENV     名前=値                 # 環境変数

CMD [コマンド, 引数]            # コンテナ起動時に実行するコマンド

# 設定は上から下へ読み込まれる
# 設定一行ごとにベースイメージに対して新しいイメージ層が形成される

# RUN / COPYはベースイメージから新たなDockerイメージを作成する際
# 作成されるDockerイメージに対して一度だけ実行される
# CMDは新たに作成されたDockerイメージからコンテナ作成時に一度だけ実行される
```
1. `$ docker build -t 作成するDockerイメージ名 /path/to/Dockerfile`を実行
2. `$ docker run --name 作成したDockerイメージ名`を実行
