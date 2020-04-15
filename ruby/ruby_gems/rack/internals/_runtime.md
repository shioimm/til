# Rack::Runtime
- 引用: [rack/lib/rack/runtime.rb](https://github.com/rack/rack/blob/master/lib/rack/runtime.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- リクエストの処理にかかった時間を示す"X-Runtime"ヘッダをレスポンスに設定するためのミドルウェア
- アプリケーションの直前に置く以外にも、
  他のミドルウェアの前に置くことによってそれらの時間を含めることもできる

## `Rack::Runtime#call`
```
    def call(env)
      start_time = Utils.clock_time
      status, headers, body = @app.call(env)
      headers = Utils::HeaderHash[headers]

      request_time = Utils.clock_time - start_time

      unless headers.key?(@header_name)
        headers[@header_name] = FORMAT_STRING % request_time
      end

      [status, headers, body]
    end
```
