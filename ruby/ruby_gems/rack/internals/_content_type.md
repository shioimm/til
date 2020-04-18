# Rack::ContentType
- 引用: [rack/lib/rack/content_type.rb](https://github.com/rack/rack/blob/master/lib/rack/content_type.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- レスポンスのデフォルトのContent-Typeヘッダを設定するミドルウェア
- Content-Typeヘッダを持たないレスポンスに対してContent-Typeヘッダを設定する

## `Rack::ContentType#call`
```ruby
    def call(env)
      status, headers, body = @app.call(env)
      headers = Utils::HeaderHash[headers]

      unless STATUS_WITH_NO_ENTITY_BODY.key?(status.to_i)
        headers[CONTENT_TYPE] ||= @content_type
      end

      [status, headers, body]
    end
```
