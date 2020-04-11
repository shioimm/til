# Rack::Cascade
- 引用: [rack/lib/rack/cascade.rb](https://github.com/rack/rack/blob/master/lib/rack/cascade.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- アプリケーションが見つからない場合、またはメソッドがサポートされていないレスポンスを返した場合、
  追加のRackアプリケーションを試行するためのヘルパー
- 複数のアプリケーションに対してリクエストを試みる
  - ステータスコードが404や405ではない(または設定されたステータスコードのリストに含まれる)、最初のレスポンスを返す
  - 試したすべてのアプリケーションが設定されたステータスコードのいずれかを返した場合、最後のレスポンスを返す

## `Rack::Cascade#call`
- 各アプリケーションを順番に呼び出す
- カスケードを必要とするステータスを使用している場合、次のアプリケーションを試行する
- すべてのレスポンスがカスケードを必要とする場合は最後のアプリからのレスポンスを返す
```ruby
    def call(env)
      return [404, { CONTENT_TYPE => "text/plain" }, []] if @apps.empty?
      result = nil
      last_body = nil

      @apps.each do |app|
        # The SPEC says that the body must be closed after it has been iterated
        # by the server, or if it is replaced by a middleware action. Cascade
        # replaces the body each time a cascade happens. It is assumed that nil
        # does not respond to close, otherwise the previous application body
        # will be closed. The final application body will not be closed, as it
        # will be passed to the server as a result.
        last_body.close if last_body.respond_to? :close

        result = app.call(env)
        return result unless @cascade_for.include?(result[0].to_i)
        last_body = result[2]
      end

      result
    end
```

### 参考
#### X-Cascade header
- 引用: [what is X-Cascade header](https://stackoverflow.com/questions/5643907/what-is-x-cascade-header)
- サーバーによって"pass"と設定されることにより、複数のルートをネスト/スタック化することができる
```
"X-Cascade" => "pass"
```
- 特定のハンドラがリクエストを処理できない場合、他のミドルウェアにリクエストを渡す目的で使用される
