# ミドルウェア
#### Rack::CommonLogger
- [rack/lib/rack/`common_logger.rb`](https://github.com/rack/rack/blob/master/lib/rack/common_logger.rb)
- Apacheフォーマットによるログファイルを作成する
  - [Apache common log format](http://httpd.apache.org/docs/2.4/logs.html#common)
- 与えられたappへのすべてのリクエストを転送し、設定されたロガーに記録する

#### Rack::ConditionalGet
- [rack/lib/rack/`conditional_get.rb`](https://github.com/rack/rack/blob/master/lib/rack/conditional_get.rb)
- レスポンスが変更されていない場合に`304 Not Modified`を返す
- `If-None-Match` / `If-Modified-Since`を使った条件付きGETを可能にする
  - アプリケーションは`Last-Modified`またはetagレスポンスヘッダのどちらか
    あるいは両方を設定する必要がある (RFC2616)
  - 条件付きGETがマッチした場合、レスポンスボディの生成を回避することができる

#### Rack::Config
- [rack/lib/rack/config.rb](https://github.com/rack/rack/blob/master/lib/rack/config.rb)
- リクエストを処理する前に環境を変更する

```ruby
use Rack::Config do |env|
  env['foo'] = 'bar'
end
```

#### Rack::ContentLength
- [rack/lib/rack/`content_length.rb`](https://github.com/rack/rack/blob/master/lib/rack/content_length.rb)
- `Content-Length`や`Transfer-Encoding`ヘッダを持たないレスポンスに対して
  レスポンスボディのサイズに応じた`Content-Length`ヘッダを設定する

#### Rack::ContentType
- [rack/lib/rack/`content_type.rb`](https://github.com/rack/rack/blob/master/lib/rack/content_type.rb)
- `Content-Type`ヘッダを持たないレスポンスに対してデフォルトの`Content-Type`ヘッダを設定する

```ruby
use Rack::ContentType, "text/plain"
```

#### Rack::Deflater
- [rack/lib/rack/deflater.rb](https://github.com/rack/rack/blob/master/lib/rack/deflater.rb)
- gzipを用いてHTTPレスポンスのコンテンツをエンコーディングし、圧縮を行う

#### Rack::ETag
- [rack/lib/rack/etag.rb](https://github.com/rack/rack/blob/master/lib/rack/etag.rb)
- レスポンスボディがバッファリング可能だった場合に`ETag`レスポンスヘッダを設定する

#### Rack::Events
- [rack/lib/rack/events.rb](https://github.com/rack/rack/blob/master/lib/rack/events.rb)
- リクエスト受信時 / レスポンス送信時にイベントを発火させるフックを提供する
  - `on_start(request, response)`
  - `on_commit(request, response)`
  - `on_send(request, response)`
  - `on_finish(request, response)`
  - `on_error(request, response, error)`

#### Rack::Files
- [rack/lib/rack/files.rb](https://github.com/rack/rack/blob/master/lib/rack/files.rb)
- リクエストパスに応じて、指定された`root/`ディレクトリ以下の静的ファイルを配信する

#### Rack::Head
- [rack/lib/rack/head.rb](https://github.com/rack/rack/blob/master/lib/rack/head.rb)
- `HEAD`リクエストに空のボディを返す

#### Rack::Lint
- [rack/lib/rack/lint.rb](https://github.com/rack/rack/blob/master/lib/rack/lint.rb)
- Rack APIへの適合性をチェックする
- アプリケーション・リクエスト・レスポンスがRackの仕様に準拠しているかどうかを検証する

#### Rack::Lock
- [rack/lib/rack/lock.rb](https://github.com/rack/rack/blob/master/lib/rack/lock.rb)
- 全てのリクエストをmutexの中にロックし、全てのリクエストが同期して実行されるようにする

#### Rack::Logger
- [rack/lib/rack/logger.rb](https://github.com/rack/rack/blob/master/lib/rack/logger.rb)
- ロギングエラーを処理するロガーを設定する

#### Rack::MethodOverride
- [rack/lib/rack/`method_override.rb`](https://github.com/rack/rack/blob/master/lib/rack/method_override.rb)
- 送信されたパラメータに基づいてリクエストメソッドを変更する

#### Rack::Recursive
- [rack/lib/rack/recursive.rb](https://github.com/rack/rack/blob/master/lib/rack/recursive.rb)
- Rack::ForwardRequestを捕捉し、現在のリクエストを指定のURLにあるアプリケーションにリダイレクトする

#### Rack::Reloader
- [rack/lib/rack/reloader.rb](https://github.com/rack/rack/blob/master/lib/rack/reloader.rb)
- ファイルが変更された場合に再読み込みする

#### Rack::Runtime
- [rack/lib/rack/runtime.rb](https://github.com/rack/rack/blob/master/lib/rack/runtime.rb)
- リクエストを処理するのにかかった時間を`X-Runtime`レスポンスヘッダに設定する

#### Rack::Sendfile
- [rack/lib/rack/sendfile.rb](https://github.com/rack/rack/blob/master/lib/rack/sendfile.rb)
- ボディがファイルから提供されているレスポンスに割り込み、サーバー固有の`X-Sendfile`ヘッダに置き換える
- ファイルシステムのパスに対して最適化されたファイルを提供することができるフロントサーバーとの連携を提供する

#### Rack::ShowExceptions
- [rack/lib/rack/`show_exceptions.rb`](https://github.com/rack/rack/blob/master/lib/rack/show_exceptions.rb)
- ミドルウェア内側で発生した例外を捕捉し、バックトレースを表示する
  - バックトレースはソースファイル、クリック可能なコンテキスト、Rack環境、リクエストデータを含む

#### Rack::ShowStatus
- [rack/lib/rack/`show_status.rb`](https://github.com/rack/rack/blob/master/lib/rack/show_status.rb)
- 空のレスポンスに対して適切なエラーページを表示する

#### Rack::Static
- [rack/lib/rack/static.rb](https://github.com/rack/rack/blob/master/lib/rack/static.rb)
- 静的ファイル配信を細かく設定する
- 静的ファイルへのリクエストを、オプションで渡されたURLプレフィックスやルートマッピングに基づいて
  受け取りRack::Filesオブジェクトを使って提供する

```ruby
use Rack::Static, :urls => ["/static"]
```

#### Rack::TempfileReaper
- [rack/lib/rack/`tempfile_reaper.rb`](https://github.com/rack/rack/blob/master/lib/rack/tempfile_reaper.rb)
- リクエスト中に作成されたtempファイルを削除する

#### Rack::Auth::Basic
- [rack/lib/rack/auth/basic.rb](https://github.com/rack/rack/blob/master/lib/rack/auth/basic.rb)
- RFC2617に基づくHTTP Basic認証を提供する

#### Rack::Auth::AbstractHandler
- [rack/lib/rack/auth/basic.rb](https://github.com/rack/rack/blob/master/lib/rack/auth/basic.rb)
- 共通の認証機能を提供するハンドラ

#### Rack::Auth::Digest::MD5
- [rack/auth/digest/md5.rb](https://github.com/rack/rack/blob/master/lib/rack/auth/digest/md5.rb)
- RFC 2617に基づくMD5アルゴリズムによるHTTPダイジェスト認証を提供する

#### Rack::Auth::Digest::Nonce
- [rack/auth/digest/nonce.rb](https://github.com/rack/rack/blob/master/lib/rack/auth/digest/nonce.rb)
- `Rack::Auth::Digest::MD5`ハンドラ用のデフォルトのnonceジェネレータ

#### Rack::Session::Cookie
- [rack/lib/rack/session/cookie.rb](https://github.com/rack/rack/blob/master/lib/rack/session/cookie.rb)
- Cookieベースのセッション管理を提供する
  - デフォルトでは、セッションはbase64エンコードデータをキーに設定したRubyハッシュとして格納される
  - 秘密鍵が設定されるとCookieはデータの整合性をチェックする

#### Rack::Session::Pool
- [rack/lib/rack/session/pool.rb](https://github.com/rack/rack/blob/master/lib/rack/session/pool.rb)
- シンプルなCookieベースのセッション管理を提供する

## 参照
- [Available middleware shipped with Rack](https://github.com/rack/rack#available-middleware-shipped-with-rack-)
