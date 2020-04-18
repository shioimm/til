# Sidekiq
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP324-328
- Sidekiq -> 非同期処理ツール
- Redis -> Sidekiqが使用するDB(KVS)
- Sidekiqはgem、Redisはbrewでインストール
- Sidekiqは`$ sidekiq`コマンド、Redisは`$ redis-server`コマンドで起動

### ジョブの生成
```sh
$ rails g job sample
```

```ruby
class SampleJob < ApplictionJob
  queue_as :default

  def perform(*args)
    # ジョブを記述
  end
end
```

```ruby
# ジョブを使用する箇所
# perform_laterで非同期処理になる

SampleJob.perform_later
```
