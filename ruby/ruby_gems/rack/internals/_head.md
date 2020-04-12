# Rack::Head
- 引用: [rack/lib/rack/head.rb](https://github.com/rack/rack/blob/master/lib/rack/head.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- HEADリクエストに対して空のボディを返すためのミドルウェア
- 他のリクエストは変更されない

## `Rack::Head#call`
```
    def call(env)
      status, headers, body = @app.call(env)

      if env[REQUEST_METHOD] == HEAD
        [
          status, headers, Rack::BodyProxy.new([]) do
            body.close if body.respond_to? :close
          end
        ]
      else
        [status, headers, body]
      end
    end
```
