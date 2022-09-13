# ヘルパー
#### Rack::Request
- [rack/lib/rack/request.rb](https://github.com/rack/rack/blob/master/lib/rack/request.rb)
- Rack envへのインターフェース、クエリ文字列の解析、マルチパート処理を提供する
  - 引数`env`として渡した環境変数を操作する

```ruby
req = Rack::Request.new(env)
req.post?
req.params["data"]
```

#### Rack::Response
- [rack/lib/rack/response.rb](https://github.com/rack/rack/blob/master/lib/rack/response.rb)
- レスポンスを生成するためのインターフェース、ヘッダとCookie関連の処理を提供する

#### Rack::MockRequest / Rack::MockResponse
- [rack/lib/rack/mock.rb](https://github.com/rack/rack/blob/master/lib/rack/mock.rb)
- HTTPラウンドトリップなしでRackアプリケーションをテストするためのモックを提供する
- `Rack::MockRequest`でURLに対してリクエストを実行すると、`Rack::MockResponse`が返される

#### Rack::Cascade
- [rack/lib/rack/cascade.rb](https://github.com/rack/rack/blob/master/lib/rack/cascade.rb)
- アプリケーションが`Not Found`や`Method Not Supported`レスポンスを返した際、
  他のRackアプリケーションを試行することで404や405を回避しようとする
- 最後に試行したアプリケーションが404や405であった場合は取得したレスポンスをそのまま返す

#### Rack::Directory
- [rack/lib/rack/directory.rb](https://github.com/rack/rack/blob/master/lib/rack/directory.rb)
- 指定されたディレクトリ下でディレクトリインデックスを使ってファイルを提供する
- リクエストパスに従って、与えられた`root/`以下のエントリを提供する
  - ディレクトリが見つかった場合、ファイルの内容がHTMLベースのインデックスとして表示される
  - ファイルが見つかった場合、指定された`app`に`env`が渡される
    - Rackアプリケーションが指定されていない場合、同じディレクトリの`Rack::Files`が使用される

#### Rack::MediaType
- [rack/lib/rack/`media_type.rb`](https://github.com/rack/rack/blob/master/lib/rack/media_type.rb)
- `Content-Type`ヘッダからメディアタイプとパラメータを解析する

#### Rack::Mime
- [rack/lib/rack/mime.rb](https://github.com/rack/rack/blob/master/lib/rack/mime.rb)
- ファイルの拡張子に基づいて`Content-Type`を決定する

#### Rack::RewindableInput
- [rack/lib/rack/`rewindable_input.rb`](https://github.com/rack/rack/blob/master/lib/rack/rewindable_input.rb)
- あらゆるIOオブジェクトをrewindableにする
  - データを巻き戻し可能なtempfileにバッファリングすることによって実現する

#### Rack::URLMap
- [rack/lib/rack/urlmap.rb](https://github.com/rack/rack/blob/master/lib/rack/urlmap.rb)
- 同じプロセス内の複数のアプリケーションにルーティングする
- アプリケーションへのURL・パスをマッピングしたハッシュを受け取り、それに応じてディスパッチする

## 参照
- [Convenience interfaces](https://github.com/rack/rack#convenience-interfaces)
