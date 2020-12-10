# 内部実装
- 参照: [rack/rack](https://github.com/rack/rack)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 基本
### module Rack
- [module Rack](https://github.com/rack/rack/blob/master/lib/rack.rb)
- Rackのメインモジュール
  - 定数定義
  - モジュールのオートローディング
- すべてのRackのコアモジュールの名前空間として機能する
```
Rack
  |
  |- Auth
  |    |- Digest
  |
  |- Session
```

### Rack::Server
- [rack/lib/rack/server.rb](https://github.com/rack/rack/blob/master/lib/rack/server.rb)
- `Rack::Server.start`を呼び新しいRackサーバーを起動する(`$ rackup`)
- デフォルトで`config.ru`をロードする

### Rack::Builder
- [rack/lib/rack/builder.rb](https://github.com/rack/rack/blob/master/lib/rack/builder.rb)
- Rackアプリケーションを反復的に構築するためのDSLの実装
  - `use` - スタックにミドルウェアを追加する
  - `run` - アプリケーションにディスパッチする
  - `map` - `Rack::URLMap`を構築する

### Rack::Handler
- [rack/lib/rack/handler.rb](https://github.com/rack/rack/blob/master/lib/rack/handler.rb)
- アプリケーションサーバーをRackに接続する
- Rack本体にはThin、WEBrick、FastCGI、CGI、SCGI、LiteSpeed用のハンドラが含まれる
- 通常、ハンドラは`MyHandler.run(myapp)`を呼び出すことで起動する

## 便利
### Rack::BodyProxy
- [rack/lib/rack/body_proxy.rb](https://github.com/rack/rack/blob/master/lib/rack/body_proxy.rb)
- レスポンスボディのためのプロキシ
  - レスポンスがクライアントに対して完全に送信された後、
    レスポンスの本文をラップしブロックを呼び出すように設定する

### Rack::Multipart
- [rack/lib/rack/multipart.rb](https://github.com/rack/rack/blob/master/lib/rack/multipart.rb)
- `multipart/form-data`パーサー
  - `multipart/form-data`形式で送信されたフォームのデータをパースする
- `Rack::Request#POST`内で使用される

### Rack::NullLogger
- [rack/lib/rack/null_logger.rb](https://github.com/rack/rack/blob/master/lib/rack/null_logger.rb)
- 全てのメソッドで空の値を返すロガー

### Rack::QueryParser
- [rack/lib/rack/query_parser.rb](https://github.com/rack/rack/blob/master/lib/rack/query_parser.rb)
- クエリ文字列をパースする
- `Rack::Utils`の中で使用される

### Rack::Utils
- [rack/lib/rack/utils.rb](https://github.com/rack/rack/blob/master/lib/rack/utils.rb)
- Rubyライブラリから採用された、Webアプリケーションを書くために便利なメソッドを集めたモジュール
