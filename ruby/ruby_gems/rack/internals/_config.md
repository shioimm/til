# Rack::Config
- 引用: [rack/lib/rack/config.rb](https://github.com/rack/rack/blob/master/lib/rack/config.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- リクエストを処理する前に環境を変更するミドルウェア
- 初期化時に与えられたブロックを使用して環境を変更する

## `Rack::Config#call`
```ruby
    def call(env)
      @block.call(env)
      @app.call(env)
    end
```
