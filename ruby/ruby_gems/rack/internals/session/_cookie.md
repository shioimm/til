# Rack::Session::Cookie
- 引用: [rack/lib/rack/session/cookie.rb](https://github.com/rack/rack/blob/master/lib/rack/session/cookie.rb)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- Cookieベースのセッション管理を提供する
- デフォルトにおいて、セッションはBase64 encoded marshalled dataとして格納されたRubyハッシュ
  - `key: rack.session`
- セッションデータをエンコードするオブジェクトはconfigurable
  かつ+encode+と+decode+に対応している必要がある
  - +encode+と+decode+はいずれも文字列を受け取り、文字列を返す必要がある
- 秘密鍵が設定されると、Cookieのデータの整合性がチェックされる
  - 古い秘密鍵も受け入れられ、secret rotationを可能にする

### 例
```ruby
use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'foo.com',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'change_me',
                           :old_secret => 'also_change_me'
```
```ruby
Rack::Session::Cookie.new(application, {
  :coder => Rack::Session::Cookie::Identity.new
})
```
