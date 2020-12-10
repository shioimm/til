# ヘルパー
- 引用: [Convenience](https://github.com/rack/rack#convenience-)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## Rack::Request
- [rack/lib/rack/request.rb](https://github.com/rack/rack/blob/master/lib/rack/request.rb)
- Rack envへのインターフェースの提供、クエリ文字列の解析、マルチパート処理を行うヘルパー
  - 引数`env`として渡した環境変数を操作する

## Rack::Response
- [rack/lib/rack/response.rb](https://github.com/rack/rack/blob/master/lib/rack/response.rb)
- レスポンスを生成するためのインターフェースの提供、ヘッダとCookie関連の処理を行うヘルパー

## Rack::MockRequest / Rack::MockResponse
- [rack/lib/rack/mock.rb](https://github.com/rack/rack/blob/master/lib/rack/mock.rb)
- HTTPを使わずにRackアプリケーションをテストするためのモックを提供するヘルパー
- `Rack::MockRequest`でURLに対してリクエストを実行すると、`Rack::MockResponse`が返される

## Rack::Cascade
- [rack/lib/rack/cascade.rb](https://github.com/rack/rack/blob/master/lib/rack/cascade.rb)
- Rackアプリケーションが見つからない場合、あるいはメソッドがサポートされていないレスポンスを返した場合、
  他のRackアプリケーションを試行するヘルパー
- 複数のアプリケーションに対し、ステータスコードに応じて順番にリクエストを試みる

## Rack::Directory
- [rack/lib/rack/directory.rb](https://github.com/rack/rack/blob/master/lib/rack/directory.rb)
- 指定のディレクトリ下でディレクトリインデックスを使ってファイルを提供するヘルパー
- Rackリクエストのパス情報に応じて、指定のディレクトリ以下のエントリを提供する
  - ディレクトリが見つかった場合、ファイルの内容はHTMLベースのインデックスで表示される
  - ファイルが見つかった場合は、指定のRackアプリケーションに渡される
    - Rackアプリケーションが指定されていない場合、同じディレクトリの`Rack::Files`が使用される

## Rack::MediaType
- [rack/lib/rack/media_type.rb](https://github.com/rack/rack/blob/master/lib/rack/media_type.rb)
- `Content-Type`ヘッダからメディアタイプとパラメータを解析するヘルパー

## Rack::Mime
- [rack/lib/rack/mime.rb](https://github.com/rack/rack/blob/master/lib/rack/mime.rb)
- ファイルの拡張子に基づいて`Content-Type`を決定するヘルパー

## Rack::RewindableInput
- [rack/lib/rack/rewindable_input.rb](https://github.com/rack/rack/blob/master/lib/rack/rewindable_input.rb)
- データを一時ファイルにバッファリングして任意のIOオブジェクトをrewindableにするヘルパー

## Rack::URLMap
- [rack/lib/rack/urlmap.rb](https://github.com/rack/rack/blob/master/lib/rack/urlmap.rb)
- 同じプロセス内の複数のアプリケーションにルーティングするヘルパー
- アプリケーションへのURL・パスをマッピングしたハッシュを受け取り、それに応じてディスパッチする
