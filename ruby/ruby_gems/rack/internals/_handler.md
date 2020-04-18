# Rack::Handler
- 引用: [rack/lib/rack/handler.rb](https://github.com/rack/rack/blob/master/lib/rack/handler.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- WebサーバーをRackに接続する
- Rack本体にはThin、WEBrick、FastCGI、CGI、SCGI、LiteSpeed用のハンドラが含まれる
- 通常、ハンドラは`<tt>MyHandler.run(myapp)</tt>`を呼び出すことで起動する
- オプションのハッシュを渡すことによりサーバ固有の設定を含めることができる
