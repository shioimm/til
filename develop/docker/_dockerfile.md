# Dockerfile
- 参照: [Dockerfile リファレンス](https://docs.docker.jp/engine/reference/builder.html)
- 新しいDockerイメージを構築するための設定ファイル
```
FROM    # ベースとなるイメージ

WORKDIR # ワークディレクトリ

COPY    # ホストからコンテナへコピーするファイル

RUN     # docker build時に実行するシェルコマンド
```
