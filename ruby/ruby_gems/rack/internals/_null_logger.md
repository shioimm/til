# Rack::NullLogger
- 引用: [rack/lib/rack/null_logger.rb](https://github.com/rack/rack/blob/master/lib/rack/null_logger.rb)

## 概要
- 全てのメソッドで空の値を返すロガー

## `Rack::NullLogger#call`
```ruby
    def call(env)
      env[RACK_LOGGER] = self
      @app.call(env)
    end
```
