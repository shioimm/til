# Sidekiq
- 参照: [Sidekiq](https://github.com/mperham/sidekiq)

## TL;DR
- ジョブ管理のためのシンプルで効率的なバックグラウンドライブラリ
- スレッドを使用して複数のジョブを同じプロセスで同時に処理する
- Railsと連携して動作するための機能が充実している

## 構成要素
### Sidekiqクライアント
- ジョブを生成しキューイングするためのAPI
- 任意のRubyプロセス(Pumaなど)で動作する

### Redis
- Sidekiqのデータストレージとして動作する
  - 全てのジョブデータの他、SidekiqのWeb UIのためのランタイムデータや履歴データを保持する
- Redisに接続するためには`Sidekiq.configure_server`と`Sidekiq.configure_client`に
  RedisのURLを設定することが必要
- Redisには複数のトポロジーが存在するため、
  SidekiqにはRedis Sentinelか、フェイルオーバーをサポートしているRedis SaaSが推奨される

### サーバー
- Redisのキューからジョブを取り出して処理するためのプロセス
- サーバーはワーカーのインスタンスを生成し、与えられた引数で`perform`を呼び出す

## ジョブの状態
- Scheduled
  - 将来のある時点で実行されるよう設定されている状態
- Enqueued
  - 処理中のキューにおいて順番待ちをしている状態
- Busy
  - 処理中の状態
- Processed
  - 正常に完了した状態
- Retries
  - 失敗し、将来的に自動で再実行されるよう設定されている状態
- Dead
  - 再試行されず、手動で再試行できるように保存されている状態
- その他
  - Failed
    - エラーが発生した回数
