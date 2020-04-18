# Rack::Session::Pool
- 引用: [rack/lib/rack/session/pool.rb](https://github.com/rack/rack/blob/master/lib/rack/session/pool.rb)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- Cookieベースのセッション管理を提供する
- セッションデータは`@pool`が保持するハッシュに格納される
- マルチスレッド環境においてはールにコミットされたセッションはマージされる

### 例
```ruby
myapp = MyRackApp.new
sessioned = Rack::Session::Pool.new(myapp,
  :domain => 'foo.com',
  :expire_after => 2592000
)
Rack::Handler::WEBrick.run sessioned
```
