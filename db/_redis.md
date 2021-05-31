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

## Redis CLI
```
$ redis-cli

127.0.0.1:xxxx> keys *       キー名一覧を取得
127.0.0.1:xxxx> type キー名  キーの型を取得
127.0.0.1:xxxx> get  キー名  キーの値を取得
127.0.0.1:xxxx> ttl  キー名  キーの期限を取得
127.0.0.1:xxxx> del  キー名  特定のキーを削除
127.0.0.1:xxxx> monitor      リアルタイムモニタリング
```

## 参照
- [Redis](https://redis.io/)
- [Redis](https://ja.wikipedia.org/wiki/Redis)
