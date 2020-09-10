# Dockerfile
- 参照: [Dockerfile リファレンス](https://docs.docker.jp/engine/reference/builder.html)
- 新しいDockerイメージを構築するための設定ファイル
```
FROM    # ベースとなるイメージ

WORKDIR # ワークディレクトリ

COPY    # ホストからコンテナへコピーするファイル

RUN     # docker build時に実行するシェルコマンド

ENV     # 環境変数

CMD     # コンテナ起動時に実行されるコマンド
```
- 設定は上から下へ読み込まれる
- 設定一行ごとにベースとなるイメージに対して新しいイメージ層が形成される
