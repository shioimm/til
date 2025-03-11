# initializers
- initializers以下のファイルはアプリケーション起動時に一度だけ読み込まれる
- Railsアプリケーションでグローバル変数を使用する際はinitializerで一度だけ読み込むようにし、
  アプリケーション内で変更しないようにする

```ruby
$redis = Redis.new(url: ENV["REDIS_URL"], driver: :hiredis)
```
