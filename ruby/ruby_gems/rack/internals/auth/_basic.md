# Rack::Auth::Basic
- 引用: [rack/lib/rack/auth/basic.rb](https://github.com/rack/rack/blob/master/lib/rack/auth/basic.rb)

## 概要
- RFC2617に基づくHTTP Basic認証を提供する

## `Rack::Auth::Basic#call`
```ruby
      def call(env)
        auth = Basic::Request.new(env)

        return unauthorized unless auth.provided?

        return bad_request unless auth.basic?

        if valid?(auth)
          env['REMOTE_USER'] = auth.username

          return @app.call(env)
        end

        unauthorized
      end
```
