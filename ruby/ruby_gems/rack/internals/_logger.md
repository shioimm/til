# Rack::Logger
- 引用: [rack/lib/rack/logger.rb](https://github.com/rack/rack/blob/master/lib/rack/logger.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- ロギングエラーを処理するロガーを設定するためのミドルウェア
- rack.loggerをrack.errorsストリームに書き込むように設定を行う

## `Rack::Logger#call`
```ruby
    def call(env)
      logger = ::Logger.new(env[RACK_ERRORS])
      logger.level = @level

      env[RACK_LOGGER] = logger
      @app.call(env)
    end
```
