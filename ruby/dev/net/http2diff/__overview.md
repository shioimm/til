## 新公開API
- lib/net/http/client.rb

## 既存APIへの変更
- lib/net/http.rb
- lib/net/http/header.rb
- lib/net/http/response.rb

## 接続確立の共通処理
- lib/net/http/connection.rb

## クライアント基盤
- lib/net/http/client/runtime.rb (例外、キャンセル、タイムアウトなどのハンドリング)
- lib/net/http/client/request.rb (リクエストボディの生成)
- lib/net/http/client/response.rb (レスポンスボディの展開)
- lib/net/http/client/cookie_jar.rb (レスポンスのSet-Cookieを保持し、以降のリクエストにCookieヘッダを付与)

## コネクションプール・プロトコル選択
- lib/net/http/client/pool.rb (コネクションの予約 / 解放 / 待機の管理)
- lib/net/http/client/connection_factory.rb (TCP/TLS接続、ALPN)

## HTTP/2実装
- lib/net/http/client/http2/session.rb (HTTP/2のフレーミング・ストリーム・フロー制御)
- lib/net/http/client/http2/hpack.rb (HPACK)

## 旧APIとの互換ブリッジ
- lib/net/http/convenience.rb
