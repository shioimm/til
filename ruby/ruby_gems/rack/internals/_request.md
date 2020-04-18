# Rack::Request
- 引用: [rack/lib/rack/request.rb](https://github.com/rack/rack/blob/master/lib/rack/request.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- Rack環境へのインターフェースを提供する
  - ステートレスであり、コンストラクタに渡された環境+env+は直接変更される
- クエリ文字列の解析とマルチパート処理を提供するヘルパーとして使用できる
```ruby
req = Rack::Request.new(env)
req.post?
req.params["data"]
```
