# Rack::ShowStatus
- 引用: [rack/lib/rack/show_status.rb](https://github.com/rack/rack/blob/master/lib/rack/show_status.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- 空のレスポンスをキャッチし、エラーページに置き換えるミドルウェア
  - 追加の詳細は`rack.showstatus.detail`にてHTMLで表示できる

## `Rack::ShowStatus`
```ruby
    def call(env)
      status, headers, body = @app.call(env)
      headers = Utils::HeaderHash[headers]
      empty = headers[CONTENT_LENGTH].to_i <= 0

      # client or server error, or explicit message
      if (status.to_i >= 400 && empty) || env[RACK_SHOWSTATUS_DETAIL]
        # This double assignment is to prevent an "unused variable" warning.
        # Yes, it is dumb, but I don't like Ruby yelling at me.
        req = req = Rack::Request.new(env)

        message = Rack::Utils::HTTP_STATUS_CODES[status.to_i] || status.to_s

        # This double assignment is to prevent an "unused variable" warning.
        # Yes, it is dumb, but I don't like Ruby yelling at me.
        detail = detail = env[RACK_SHOWSTATUS_DETAIL] || message

        body = @template.result(binding)
        size = body.bytesize
        [status, headers.merge(CONTENT_TYPE => "text/html", CONTENT_LENGTH => size.to_s), [body]]
      else
        [status, headers, body]
      end
    end
```
