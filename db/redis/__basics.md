# Redis
- インメモリDB
  - ディスク上ではなく、より高速なメモリ上でデータの格納を行う
- NoSQL DB
- 連想配列、リスト、セットなどのデータ構造を扱うことができる
- シングルスレッド上のシングルプロセスとして動作する
- データセットをディスクにダンプするか、各コマンドをログに追加することによってデータの永続化ができる

### Railsアプリケーション開発におけるRedis
- バックグラウンドジョブにおけるジョブのキューイング
- キャッシュストア
  - アプリケーションキャッシュ
  - セッションキャッシュ

### Redisの使用箇所を確認する
- `gem 'redis'`があるかどうか
- `Redis.new`されている箇所を探す
  - `config/initializers/redis.rb`など
  - ただしSidekiqは自身のconfigの中で`config.redis`として使用している

## 参照
- [Redis](https://redis.io/)
- [Redis](https://ja.wikipedia.org/wiki/Redis)
