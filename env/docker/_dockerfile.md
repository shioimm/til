# Dockerfile
- 新しいDockerイメージを構築する際に実行するコマンドをコード化したファイル

```
# ベースとするDockerイメージ
FROM コンテナイメージ名:タグ名

# 作業ディレクトリを設定する
WORKDIR /コンテナの作業ディレクトリ名

# ホストからコンテナへファイルをコピーする
COPY /ホストのディレクトリ名/ファイル名 /コンテナのディレクトリ名

# docker build時に実行するシェルコマンド
RUN シェルコマンド名

# 環境変数を設定する
ENV 名前=値

# 外部へポートを公開する
EXPOSE ポート番号

# コンテナ起動時にコマンドを実行する
#   RUN / COPYはベースイメージから新たなDockerイメージを作成する際に
#   作成されるDockerイメージに対して一度だけ実行される
#   CMDは新たに作成されたDockerイメージからコンテナ作成時に一度だけ実行される
CMD [コマンド, 引数]

# コンテナが起動したらファイルを実行する
ENTRYPOINT ["コンテナ内のファイル名"]
```
1. `$ docker build -t 作成するDockerイメージ名 /path/to/Dockerfile`を実行
2. `$ docker run --name 作成したDockerイメージ名`を実行

## キャッシュ
- DockerはDockerfileの各命令を実行するたび、各変更差分をキャッシュしながらビルドを進めていく
- 以降のビルドでは、前回のビルド時と得られる結果が異なるステップのみ実行され、
  同じ変更差分が期待されるステップについてはキャッシュを活用する

## 参照
- [Dockerfile リファレンス](https://docs.docker.jp/engine/reference/builder.html)
- [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その3:Dockerfileってなに？ 〜](https://tech-lab.sios.jp/archives/19191)
- イラストでわかるDocker & Kubernetes
