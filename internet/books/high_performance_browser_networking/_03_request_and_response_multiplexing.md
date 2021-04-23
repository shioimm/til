# HTTP/2 (High Performance Browser Networking | O'Reilly)まとめ
- 引用: [HTTP/2](https://hpbn.co/http2/)

## Request and Response Multiplexing
- 引用: [Request and Response Multiplexing](https://hpbn.co/http2/#request-and-response-multiplexing)

### データ転送におけるHTTP/1.xとHTTP/2の違い
- HTTP/1.x -> 一つのコネクションごとに一つのリクエスト・レスポンスを扱う
  - 並列して複数のリクエスト・レスポンスを扱う場合は複数のTCP接続が必要
- HTTP/2 -> 一つのコネクションごとに複数のリクエスト・レスポンスを(ストリームとして)扱う
  - クライアントとサーバーはBinary Framing層によって
    HTTPメッセージを独立したフレームに分解してインターリーブし、
    転送後に再アセンブルする

### 重要点
```
HTTP/2はHTTPメッセージを独立したフレームに分解し、インターリーブし、反対側で再アセンブルする
```
- HTTP/2はノンブロッキングで複数のリクエストを並行してインターリーブする
- HTTP/2はノンブロッキングで複数のレスポンスを並行してインターリーブする
- HTTP/2は一つのコネクションによってを複数のリクエストとレスポンスを並行して転送する
- HTTP/2によってHTTP/1.xで使用されていた連結ファイル、イメージスプライト、ドメインシャーディングなどの回避策が不要になる
- HTTP/2が不要なレイテンシーを排除し、利用可能なネットワーク容量の使用率を向上させることによって、
  ページのロード・タイムが短縮される
- HTTP/2はHTTP/1.xで使用されていた複数コネクションの必要性を排除する
