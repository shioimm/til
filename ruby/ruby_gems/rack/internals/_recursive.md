# Rack::Recursive
- 引用: [rack/lib/rack/recursive.rb](https://github.com/rack/rack/blob/master/lib/rack/recursive.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 引用: [RackReferenceJa](https://route477.net/w/RackReferenceJa.html)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- アプリケーション内の他のパスからのデータを含め、内部リダイレクトを行うミドルウェア
  - アプリケーション内から別のパスに飛ばせるようにする
- チェーンの下で呼び出されたアプリケーションが他のアプリケーションからデータを取り込む
- `rack['rack.recursive.include']`を使用したり、ForwardRequestを発行することにより内部的にリダイレクトさせる

## `Rack::Recursive#call`
```ruby
    def call(env)
      dup._call(env)
    end

    def _call(env)
      @script_name = env[SCRIPT_NAME]
      @app.call(env.merge(RACK_RECURSIVE_INCLUDE => method(:include)))
    rescue ForwardRequest => req
      call(env.merge(req.env))
    end
```
