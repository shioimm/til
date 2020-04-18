# Rack::Response
- 引用: [rack/lib/rack/response.rb](https://github.com/rack/rack/blob/master/lib/rack/response.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- Rackのレスポンスを生成するための便利なインターフェイスを提供する
- HTTPレスポンスの生成とCookieの処理を便利にすることができるヘルパーとして利用できる
- ヘッダとCookieを設定することができ、デフォルト値を提供する
  - デフォルト値: `[200, {}, []]`
- `Response#write`を使って反復的にレスポンスを生成することができる
  - +finish+を呼び出すまではRack::Responseによってバッファリングされている
  - +finish+は+write+の呼び出しがRackのレスポンスと同期しているブロックを内部に取ることができる
  - +call+ は`Response#finish`を返して終了する
