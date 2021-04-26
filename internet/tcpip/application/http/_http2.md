# HTTP/2
## TL;DR
- HTTP/1.1のセマンティクスを変更せず、より効率よくHTTPメッセージを送信するためのプロトコル
- 一本のTCP接続の内部に仮想のTCPソケット(ストリーム)を作成し通信を行う
- HTTP/2自身はTLSが必須ではないがHTTP/2サポートブラウザはTLSを使用する

### 目的
- Webページのリソースの増加(数、サイズ)に伴うパフォーマンス改善
  - リクエストとレスポンスの多重化によるレイテンシの低減
  - HTTPヘッダフィールドの効率的な圧縮によるプロトコルのオーバーヘッド最小化
  - リクエストの優先順位付けとサーバプッシュ機能の追加
- 「HTTPメッセージのセマンティクスを維持し、パフォーマンスとセキュリティを改善する」

### SPDY
- Googleで開発されたHTTP/2の基盤となるプロトコル

## HTTP/1.1の課題
- リクエストの処理数がTCPの数に依存している
- Webページが必要とするリソースの数だけリクエストが必要
- ヘッダーのデータサイズの大きさ

## HTTP/2の改善点
- ストリーム(HTTP/1.1のパイプライニングに近い)を使用してバイナリデータを多重に送受信する
- ストリーム内での優先順位設定を実装
- サーバーサイドからデータ通信を行うサーバープッシュ機能を実装
- ヘッダが圧縮されるようになった

## Key feature
- binary protocol
- header compression
- multiplexing
- prioritization

## 利用方法
- HTTPのテキストプロトコル内部でのバージョン切り替えではなく、
  TLSのALPN機能(プロトコル選択機能)を使い通信方式を切り替える

## ポートとスキーマ
- HTTP/1.0との互換性を保ち、使用するデフォルトのポート番号はhttpの場合80番、httpsの場合443番のまま

### 識別子
- HTTP/2通信は、ポート番号とは別にどのような方式で接続を行うかを決める識別子を持つ
  - h2(HTTP/2 over TLS -> いわゆるhttps)
  - h2c(HTTP/2 over TCP -> いわゆるhttp)

## 参照
- [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- [Request and Response](https://youtu.be/0cmXVXMdbs8)
- [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- よくわかるHTTP/2の教科書P76-78
- [【招待講演】最速ウェブサーバの作り方　奥 一穂氏](https://www.youtube.com/watch?v=Iu5Uynq7ubo&feature=youtu.be)
- Real World HTTP 第2版
