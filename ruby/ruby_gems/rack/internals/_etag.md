# Rack::Etag
- 引用: [rack/lib/rack/etag.rb](https://github.com/rack/rack/blob/master/lib/rack/etag.rb)

## 概要
- すべての文字列ボディにETagヘッダを自動的に設定する
- ETagヘッダやLast-Modifiedヘッダが送信された場合やsendfileのボディ(`body.responds_to :to_path`)が指定された場合
  ETagヘッダはスキップされる
  - その場合はapache/nginxで処理されるべきである

#### `initialize`時に渡すことができるパラメータ
- Cache-Controlディレクティブ
  - Etagが存在しない場合に使用される`cache_control`
    - 初期値: "max-age=0, private, must-revalidate"
  - Etagが存在する場合に使用される`no_cache_control`
    - 初期値: "null"

## `Rack::Etag#call`
```ruby
    def call(env)
      status, headers, body = @app.call(env)

      if etag_status?(status) && etag_body?(body) && !skip_caching?(headers)
        original_body = body
        digest, new_body = digest_body(body)
        body = Rack::BodyProxy.new(new_body) do
          original_body.close if original_body.respond_to?(:close)
        end
        headers[ETAG_STRING] = %(W/"#{digest}") if digest
      end

      unless headers[CACHE_CONTROL]
        if digest
          headers[CACHE_CONTROL] = @cache_control if @cache_control
        else
          headers[CACHE_CONTROL] = @no_cache_control if @no_cache_control
        end
      end

      [status, headers, body]
    end
```
