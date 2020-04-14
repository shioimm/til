# Rack::MethodOverride
- 引用: [rack/lib/rack/method_override.rb](https://github.com/rack/rack/blob/master/lib/rack/method_override.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- 送信されたリクエストメソッドに基づいてリクエストメソッドを変更するミドルウェア

## `Rack::MethodOverride#call`
```ruby
# allowed_methods = %w[POST]
# HTTP_METHODS = %w[GET HEAD PUT POST DELETE OPTIONS PATCH LINK UNLINK]

    def call(env)
      if allowed_methods.include?(env[REQUEST_METHOD])
        method = method_override(env)
        if HTTP_METHODS.include?(method)
          env[RACK_METHODOVERRIDE_ORIGINAL_METHOD] = env[REQUEST_METHOD]
          env[REQUEST_METHOD] = method
        end
      end

      @app.call(env)
    end
```
