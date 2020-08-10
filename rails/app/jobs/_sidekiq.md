# Sidekiq
## TL;DR
- Sidekiq -> 非同期処理ツール
- Redis -> Sidekiqが使用するDB(KVS)
  - Sidekiqはgem、Redisはbrewでインストール
  - Sidekiqは`$ sidekiq`コマンド、Redisは`$ redis-server`コマンドで起動

## `sidekiq.yml`
```yml
# config/sidekiq.yml

# 使用するキュー
:queue:
  - default
  - mailers # ActionMailerを使用する場合
```
