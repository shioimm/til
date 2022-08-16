# Dockerイメージを作る際のベストプラクティス
- 1コンテナで1プロセスのみ動作させる
- コンテナが利用するポート番号を明確にする
- 永続化するファイルの置き場所を明確にする
- 設定は環境変数で渡す
- ログを標準出力に書き出す
- デタッチしていないコンテナは実行後終了することを認識しておく

## 参照
- [Dockerfile のベストプラクティス](https://docs.docker.jp/engine/articles/dockerfile_best-practice.html)
