# Rack::ContentLength
- 引用: [rack/lib/rack/content_length.rb](https://github.com/rack/rack/blob/master/lib/rack/content_length.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- ボディのサイズに基づいてContent-Lengthヘッダを設定するミドルウェア
- Content-LengthヘッダやTransfer-Encodingヘッダを指定していないレスポンスに対して
  Content-Lengthヘッダを設定する
  - 無効なContent-Length ヘッダが指定されているレスポンスを修正するものではない

## `Rack::ContentLength#call`
```ruby
    def call(env)
      status, headers, body = @app.call(env)
      headers = HeaderHash[headers]

      if !STATUS_WITH_NO_ENTITY_BODY.key?(status.to_i) &&
         !headers[CONTENT_LENGTH] &&
         !headers[TRANSFER_ENCODING]

        obody = body
        body, length = [], 0
        obody.each { |part| body << part; length += part.bytesize }

        body = BodyProxy.new(body) do
          obody.close if obody.respond_to?(:close)
        end

        headers[CONTENT_LENGTH] = length.to_s
      end

      [status, headers, body]
    end
```
