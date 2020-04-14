# Rack::MockRequest / Rack::MockResponse
- 引用: [rack/lib/rack/mock.rb](https://github.com/rack/rack/blob/master/lib/rack/mock.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- 実際のHTTP round-tripなしで効率的かつ迅速なテストを行うことができるヘルパー

### `Rack::MockRequest`
- `GET/POST/PUT/PATCH/DELETE`でURLに対してリクエストを実行した後、
  テストのために有用なヘルパーメソッドを含むMockResponseを返す
- `GET/POST/PUT/PATCH/DELETE`ハッシュを渡して設定を追加することができる
- `input` -> `rack.input`として使用される文字列またはIO likeなオブジェクト
- `fatal` -> アプリケーションが`rack.errors`に書き込んだ場合、FatalWarningを発生させる
- `lint` -> `true`の場合、アプリケーションをRack::Lintでラップする

### `Rack::MockResponse`
- 通常MockResponseはRack::MockRequestによって利用される
