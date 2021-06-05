# HTTP/2
- HTTP/1.1のセマンティクスを変更せず、より効率よくHTTPメッセージを送信するためのプロトコル
- 一本のTCP接続の内部に仮想のTCPソケット(ストリーム)を作成し通信を行う

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
- バイナリフレームレイヤーの導入
  - ストリーム(HTTP/1.1のパイプライニングに近い)を使用してバイナリデータを多重に送受信する
  - 並列処理のために複数TCP接続が不要になった
- ストリーム内での優先順位設定を実装
- サーバーサイドからデータ通信を行うサーバープッシュ機能を実装
- ヘッダが圧縮されるようになった

## Key feature
- binary protocol
- header compression
- multiplexing
- prioritization

## ポート番号(デフォルト)
- http - 80
- https - 443

## 識別子
- どのような方式で接続を行うかを決めるためのもの
  - h2(HTTP/2 over TLS -> いわゆるhttps)
  - h2c(HTTP/2 over TCP -> いわゆるhttp)

## TLS
- HTTP/2は規格上TLSによる暗号化は不要
  - ただし実際にはほとんどのクライアントがh2c未対応
- TLS1.2以上のバージョンが必要

## ネゴシエーション
### ALPN機能(TLSのプロトコル選択機能)
1. クライアント -> サーバー
    - Client-Hello時に送信するプロトコルリストに`http/2`を含めて送信
2. サーバー -> クライアント
    - Server-Hello時にプロトコルリストから`http/2`を選択して送信

### HTTP/1.1のアップグレード
1. クライアント -> サーバー
    - HTTP/1.1以前と同じ方法でリクエストを送信
    - Connectionヘッダ・Upgradeヘッダ(識別子を値とする)・HTTP2-Settingsヘッダを送信し、
      クライアント側がHTTP/2に対応していることを示す
2. サーバー -> クライアント
    - ステータスコード101のレスポンスを返信
    - HTTP/2接続へ移行開始

### 直接開始
- サーバーがHTTP/2に対応していることがわかっている場合、クライアントから直接HTTP/2で通信を開始できる

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
- ハイパフォーマンスブラウザネットワーキング
