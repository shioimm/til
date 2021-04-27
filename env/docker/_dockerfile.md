# Dockerfile
## TL;DR
- 新しいDockerイメージを構築する際に実行するコマンドをコード化したファイル

## USAGE
```
# ベースとするDockerイメージ
FROM コンテナイメージ名:タグ名

# 作業ディレクトリの設定
WORKDIR /コンテナの作業ディレクトリ名

# ホストからコンテナへのファイルコピー
COPY /ホストのディレクトリ名/ファイル名 /コンテナのディレクトリ名

# docker build時に実行するシェルコマンド
RUN シェルコマンド名

# 環境変数
ENV 名前=値

# コンテナ起動時に実行するコマンド
#   RUN / COPYはベースイメージから新たなDockerイメージを作成する際に
#   作成されるDockerイメージに対して一度だけ実行される
#   CMDは新たに作成されたDockerイメージからコンテナ作成時に一度だけ実行される
CMD [コマンド, 引数]
```
1. `$ docker build -t 作成するDockerイメージ名 /path/to/Dockerfile`を実行
2. `$ docker run --name 作成したDockerイメージ名`を実行

## 参照
- [Dockerfile リファレンス](https://docs.docker.jp/engine/reference/builder.html)
- [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その3:Dockerfileってなに？ 〜](https://tech-lab.sios.jp/archives/19191)

