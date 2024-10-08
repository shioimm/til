# HTTP/2 (High Performance Browser Networking | O'Reilly)まとめ
- 引用: [HTTP/2](https://hpbn.co/http2/)

## Brief Introduction to Binary Framing
- 引用: [Brief Introduction to Binary Framing](https://hpbn.co/http2/#brief-introduction-to-binary-framing)
- HTTP/2の中核は、バイナリーによるlength-prefixed framing層
- HTTP/2接続が確立されると、クライアントとサーバーはフレームを交換して通信を行う
  - フレームはプロトコル内の通信の最小単位として機能する
  - すべてのフレームは、共通のヘッダを持つ

### 共通フレームヘッダ(9byte)
- フレームの長さ
  - 24bit
  - 単一フレームで最大バイトのデータを伝送する
- タイプ
  - 8bit
  - フレームの形式と意味を決定する
  - フレームタイプがわかれば、フレームの残りの部分はパーサーによって解釈される
- フラグ用のビットフィールド
  - 8bit
  - フレームタイプ固有のブール値フラグと通信する
- 予約フィールド
  - 1bit
  - 常時0が設定される
- ストリーム識別子
  - 31ビット
  - HTTP/2ストリームを一意に識別

### フレームタイプ
- DATA
  - HTTPメッセージ本文
- HEADERS
  - ストリームのヘッダーフィールド
- PRIORITY
  - ストリームの送信者推奨優先度
- RST_STREAM
  - ストリームの終了を知らせる
- SETTINGS
  - コネクションの構成パラメータ
- PUSH_PROMISE
  - 参照先リソースにサービスを提供するという約束を通知する
- PING
  - ラウンドトリップ時間の測定とlivenessチェックの実行に使用される
- GOAWAY
  - 現在の接続に対するストリームの作成を停止するよう送信先に通知する
- WINDOW_UPDATE
  - フローストリームおよび接続フロー制御の実装に使用される
- CONTINUATION
  - header block fragmentsシーケンスを継続するために使用される

### ストリームによるアプリケーションデータ送信
- アプリケーションデータ送信前に、新しいストリームを作成し、HEADERSフレームを送信する必要がある
  - HEADERSフレーム -> ストリーム依存性と重み、フラグ、HPACKでエンコードされたHTTPリクエスト・ヘッダ
- HEADERSフレーム送信後、アプリケーションのペイロードを送信するためにDATAフレームが使用される
  - ペイロードは複数のDATAフレームに分割できる
  - 最後のフレームは、フレームのヘッダーでEND_STREAMフラグを切り替えることによってメッセージの終端を示す
