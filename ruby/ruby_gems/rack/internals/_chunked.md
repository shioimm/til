# Rack::Chunked
- 引用: [rack/lib/rack/chunked.rb](https://github.com/rack/rack/blob/master/lib/rack/chunked.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- チャンク化されたエンコーディングを使用してストリーミングレスポンスを行うためのミドルウェア
- レスポンスヘッダにContent-Lengthが含まれていない場合、
  レスポンスボディにチャンク化された転送エンコーディングを適用する
- Trailerレスポンスヘッダをサポートしており、
  チャンク化されたエンコーディングで末尾のヘッダを使用できるようにする
- 使用時には+trailers+メソッドをサポートするレスポンスボディを手動で指定する必要がある

## `Rack::Chunked#call`
- Rackアプリケーションがボディを持つはずのレスポンスを返し、
  かつContent-LengthヘッダまたはTransfer-Encodingヘッダがない場合、
  チャンク化されたTransfer-Encodingを使用するようにレスポンスを修正する
```ruby
    def call(env)
      status, headers, body = @app.call(env)
      headers = HeaderHash[headers]

      if chunkable_version?(env[SERVER_PROTOCOL]) &&
         !STATUS_WITH_NO_ENTITY_BODY.key?(status.to_i) &&
         !headers[CONTENT_LENGTH] &&
         !headers[TRANSFER_ENCODING]

        headers[TRANSFER_ENCODING] = 'chunked'
        if headers['Trailer']
          body = TrailerBody.new(body)
        else
          body = Body.new(body)
        end
      end

      [status, headers, body]
    end
```
