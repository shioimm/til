# initializers
## 基礎
- initializers以下のファイルはアプリケーション起動時に一度だけ読み込まれる

### initializerを使用したTips
#### グローバル変数について
- Railsアプリケーションでグローバル変数を使用する際はinitializerで一度だけ読み込むようにし、
  アプリケーション内で変更しないようにする
```ruby
$redis = Redis.new(url: ENV["REDIS_URL"], driver: :hiredis)
```

## session_store
- 参照: [5 セッション](https://railsguides.jp/action_controller_overview.html#%E3%82%BB%E3%83%83%E3%82%B7%E3%83%A7%E3%83%B3)
- セッションデータを保存するクラス名を設定する
  - `:cookie_store`
    - `ActionDispatch::Session::CookieStore`ミドルウェアを利用してセッションをcookieに保存する
    - Railsのデフォルト
  - `:active_record_store`
    - `ActionDispatch::Session::ActiveRecordStore`ミドルウェアを利用してセッションをDBに保存する
    - `activerecord-session_store` gemが必要
  - `:mem_cache_store`
    - `ActionDispatch::Session::MemCacheStore`ミドルウェアを利用してセッションをmemcachedクラスタに保存する
    - 古い実装のため推奨されない
  - `:cache_store`
    - `ActionDispatch::Session::CacheStore`ミドルウェアを利用してセッションをRailsのキャッシュに保存する
    - アプリケーションに設定されているキャッシュ実装をそのまま利用してセッションを保存できる
  - `:disabled`
  - カスタムクラス(`ActionDispatch::Session::XxxxxStore`)
```ruby
Rails.application.config.session_store :cookie_store, key: '_xxx_session', expire_after: 1.year
```
