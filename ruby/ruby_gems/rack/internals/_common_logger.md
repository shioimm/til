# Rack::CommonLogger
- 引用: [rack/lib/rack/common_logger.rb](https://github.com/rack/rack/blob/master/lib/rack/common_logger.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- Apache-styleなログファイルを作成するためのミドルウェア
- 与えられた+app+へのすべてのリクエストを転送し、設定されたロガーに記録する

## `Rack::CommonLogger#call`
- レスポンスが返された後、すべてのリクエストをcommon_log形式でログに記録する
  - アプリが例外を発生させた場合、リクエストはロギングされない
  - ロギングはリクエストボディが完全に送信された後に行われるため、
    レスポンスボディの送信中に例外が発生した場合、リクエストはロギングされない
```ruby
    def call(env)
      began_at = Utils.clock_time
      status, headers, body = @app.call(env)
      headers = Utils::HeaderHash[headers]
      body = BodyProxy.new(body) { log(env, status, headers, began_at) }
      [status, headers, body]
    end
```
