# HTTP/2概論
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P76-78
- 参照: [【招待講演】最速ウェブサーバの作り方　奥 一穂氏](https://www.youtube.com/watch?v=Iu5Uynq7ubo&feature=youtu.be)

## HTTP/2とは
- HTTP/1.xのセマンティクスを変更せず、より効率よくHTTPメッセージを送信するためのプロトコル
- HTTP/2サポートブラウザはSSLを使用している
  - HTTP/2自身はSSLが必須ではない

### SPDY
- Googleで開発されたHTTP/2の前身的なプロトコル

## 背景
- HTTP/1.1の課題
  - リクエストの処理数がTCPの数に依存している
  - Webページが必要とするリソースの数だけリクエストが必要
  - ヘッダーのデータサイズの大きさ

## 目的
- Webページのリソースの増加(数、サイズ)に伴うパフォーマンス改善
  - リクエストとレスポンスの多重化によるレイテンシの低減
  - HTTPヘッダフィールドの効率的な圧縮によるプロトコルのオーバーヘッド最小化
  - リクエストの優先順位付けとサーバプッシュ機能の追加
- 「HTTPメッセージのセマンティクスを維持し、パフォーマンスとセキュリティを改善する」

## Key feature
- binary protocol
- header compression
- multiplexing
- prioritization

## ポートとスキーマ
- HTTP/1.0との互換性を保ち、使用するデフォルトのポート番号はhttpの場合80番、httpsの場合443番のまま

### 識別子
- HTTP/2通信は、ポート番号とは別にどのような方式で接続を行うかを決める識別子を持つ
  - h2(HTTP/2 over TLS -> いわゆるhttps)
  - h2c(HTTP/2 over TCP -> いわゆるhttp)
