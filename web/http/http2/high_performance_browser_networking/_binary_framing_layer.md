# HTTP/2 (High Performance Browser Networking | O'Reilly)まとめ
- 引用: [HTTP/2](https://hpbn.co/http2/)

## Binary Framing Layer
- 引用: [Binary Framing Layer](https://hpbn.co/http2/#binary-framing-layer)
- HTTP/2において、アプリケーション層にBinary Framing層が含まれる
  - Binary Framing層はクライアントとサーバー間で転送されるHTTPメッセージをカプセル化し、
    クライアントとサーバー間で転送する方法を決定する
- すべてのHTTP/2通信はメッセージとフレームに分割され、それぞれがバイナリ形式でエンコードされる
  - フレーミング作業はクライアントとサーバーによって行われる
- Binary Framingの利用につき、プロトコルを検査・デバッグするツールが必要
  - HTTP/1.x・HTTP/2データを伝送する暗号化されたTLSフローを検査するためにも同じツールが必要
  - [Wireshark](https://forest.watch.impress.co.jp/library/software/wireshark/)
    - パケット取得・プロトコル解析ソフト(複数プロトコル対応)
    - ネットワーク上に流れるパケット情報をリアルタイムで調査できる
