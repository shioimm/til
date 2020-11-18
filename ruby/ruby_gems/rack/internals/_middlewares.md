# ミドルウェア
- 引用: [Available middleware shipped with Rack](https://github.com/rack/rack#available-middleware-shipped-with-rack-)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## Rack::Chunked
- [rack/lib/rack/chunked.rb](https://github.com/rack/rack/blob/master/lib/rack/chunked.rb)
- レスポンスに`Content-Length`ヘッダが含まれていない場合に
  レスポンスボディにチャンク化されたエンコーディングを適用し、レスポンスをストリーミングするミドルウェア
- `Trailer`レスポンスヘッダをサポート
  - チャンク化されたエンコーディングで末尾のヘッダを使用することができる

## Rack::CommonLogger
- [rack/lib/rack/common_logger.rb](https://github.com/rack/rack/blob/master/lib/rack/common_logger.rb)
- Apache-styleなログファイルを作成するミドルウェア
- 与えられたappへのすべてのリクエストを転送し、設定されたロガーに記録する

## Rack::ConditionalGet
- [rack/lib/rack/conditional_get.rb](https://github.com/rack/rack/blob/master/lib/rack/conditional_get.rb)
- レスポンスが変更されていない場合、レスポンスをそのまま返すミドルウェア
- `If-None-Match` / `If-Modified-Since`リクエストヘッダを利用した条件付き`GET`を有効化する

## Rack::Config
- [rack/lib/rack/config.rb](https://github.com/rack/rack/blob/master/lib/rack/config.rb)
- リクエストを処理する前に環境を変更するミドルウェア

## Rack::ContentLength
- [rack/lib/rack/config.rb](https://github.com/rack/rack/blob/master/lib/rack/config.rb)
- ボディサイズに基づいて`Content-Length`ヘッダを設定するミドルウェア

## Rack::ContentType
- [rack/lib/rack/content_type.rb](https://github.com/rack/rack/blob/master/lib/rack/content_type.rb)
- `Content-Type`ヘッダを持たないレスポンスに対してデフォルトの`Content-Type`ヘッダを設定するミドルウェア

## Rack::Deflater
- [rack/lib/rack/deflater.rb](https://github.com/rack/rack/blob/master/lib/rack/deflater.rb)
-  gzipでレスポンスを圧縮するミドルウェア

## Rack::ETag
- [rack/lib/rack/etag.rb](https://github.com/rack/rack/blob/master/lib/rack/etag.rb)
- レスポンスボディに`ETag`ヘッダを設定するミドルウェア

## Rack::Events
- [rack/lib/rack/events.rb](https://github.com/rack/rack/blob/master/lib/rack/events.rb)
- リクエスト受信時 / レスポンス送信時に発火するフックを提供するミドルウェア

## Rack::Files
- [rack/lib/rack/files.rb](https://github.com/rack/rack/blob/master/lib/rack/files.rb)
- リクエストのパス情報に応じて、指定のディレクトリ以下のファイルを提供するミドルウェア

## Rack::Head
- [rack/lib/rack/head.rb](https://github.com/rack/rack/blob/master/lib/rack/head.rb)
- `HEAD`リクエストに空のボディを返すミドルウェア

## Rack::Lint
- [rack/lib/rack/lint.rb](https://github.com/rack/rack/blob/master/lib/rack/lint.rb)
- Rack APIへの適合性をチェックするミドルウェア
- アプリケーション・リクエスト・レスポンスがRackの仕様に準拠しているかどうかを検証する

## Rack::Lock
- [rack/lib/rack/lock.rb](https://github.com/rack/rack/blob/master/lib/rack/lock.rb)
- ミューテックスによってリクエストをシリアライズするミドルウェア
- すべてのリクエスト処理をミューテックスロック内で同期実行する

## Rack::Logger
- [rack/lib/rack/logger.rb](https://github.com/rack/rack/blob/master/lib/rack/logger.rb)
- エラーを処理するためのロガーを設定するミドルウェア

## Rack::MethodOverride
- [rack/lib/rack/method_override.rb](https://github.com/rack/rack/blob/master/lib/rack/method_override.rb)
- 送信されたパラメータに基づいてリクエストメソッドをオーバーライドするミドルウェア

## Rack::Recursive
- [rack/lib/rack/recursive.rb](https://github.com/rack/rack/blob/master/lib/rack/recursive.rb)
- 連鎖的に呼び出されたRackアプリケーションが別のRackアプリケーションからデータを取り込めるようにし、
  内部的にリダイレクトするようにするミドルウェア
  - リダイレクトのために`Rack::ForwardRequest`を発行する

## Rack::Reloader
- [rack/lib/rack/reloader.rb](https://github.com/rack/rack/blob/master/lib/rack/reloader.rb)
- ファイルが変更された場合にリロードを行うミドルウェア

## Rack::Runtime
- [rack/lib/rack/runtime.rb](https://github.com/rack/rack/blob/master/lib/rack/runtime.rb)
- リクエストを処理するのにかかった時間を`X-Runtime`レスポンスヘッダに設定するミドルウェア

## Rack::Sendfile
- [rack/lib/rack/sendfile.rb](https://github.com/rack/rack/blob/master/lib/rack/sendfile.rb)
- ファイルシステムのパスに合わせて最適化されたファイル提供を行うミドルウェア
- ボディがファイルから提供されているレスポンスに割り込み、サーバー固有の`X-Sendfile`ヘッダに置き換える

## Rack::ShowExceptions
- [rack/lib/rack/show_exceptions.rb](https://github.com/rack/rack/blob/master/lib/rack/show_exceptions.rb)
- アプリケーションから発生した例外をすべて捕捉し、バックトレースで表示するミドルウェア

## Rack::ShowStatus
- [rack/lib/rack/show_status.rb](https://github.com/rack/rack/blob/master/lib/rack/show_status.rb)
- 空のレスポンスを補足し、エラー画面を表示するミドルウェア

## Rack::Static
- [rack/lib/rack/static.rb](https://github.com/rack/rack/blob/master/lib/rack/static.rb)
- 静的ファイルへのリクエストに割り込み、`Rack::Files`オブジェクトによってそれらを提供するミドルウェア

## Rack::TempfileReaper
- [rack/lib/rack/tempfile_reaper.rb](https://github.com/rack/rack/blob/master/lib/rack/tempfile_reaper.rb)
- リクエスト中に作成されたtempファイルを削除するミドルウェア
