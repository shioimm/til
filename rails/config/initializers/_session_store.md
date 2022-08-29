# セッションストア
- セッションデータの保存場所を設定

```ruby
Rails.application.config.session_store :cookie_store, key: '_<AppName>_session', expire_after: 1.year
```

#### `:cookie_store`
- 保存場所: Cookie
- 利用するRackミドルウェア: `ActionDispatch::Session::CookieStore`
- デフォルト値

#### `:active_record_store`
- 保存場所: DB
- 利用するRackミドルウェア: `ActionDispatch::Session::ActiveRecordStore`
- `activerecord-session_store` gemが必要

#### `:redis_store`
- 保存場所: Redis
- 利用するRackミドルウェア: `ActionDispatch::Session::RedisStore`
- `redis-actionpack` gemが必要

#### `:mem_cache_store`
- 保存場所: memcachedクラスタ
- 利用するRackミドルウェア: `ActionDispatch::Session::MemCacheStore`
- 古い実装のため推奨されない

#### `:cache_store`
- 保存場所: Railsのキャッシュ
利用するRackミドルウェア: `ActionDispatch::Session::CacheStore`
- アプリケーションに設定されているキャッシュ実装をそのまま利用してセッションを保存できる

#### `:disabled`
- カスタムクラス (`ActionDispatch::Session::????Store`)

## 参照
- [5 セッション](https://railsguides.jp/action_controller_overview.html#%E3%82%BB%E3%83%83%E3%82%B7%E3%83%A7%E3%83%B3)
