# Handshakeプロトコル
- 暗号化されていない状態で通信を開始した後に双方でハンドシェイクを実施し、
  暗号化通信で使うセキュリティパラメータとして互いに受け入れられるものをネゴシエーションする

#### Handshakeプロトコルの役割
- 接続で使いたいパラメータを双方が提示し、一般的なセキュリティパラメータについて双方で合意する
- サーバーの真正性を検証する (オプションとしてクライアントの真正性を検証する)
- 暗号鍵をいくつか生成する
- ハンドシェイクメッセージが能動的ネットワーク攻撃者によって書き換えられていないことを検証する

## Handshakeメッセージフォーマット
- メッセージタイプ (1バイト)
- メッセージ長 (3バイト)
- メッセージ本体

```c
struct {
  HandshakeType msg_type;
  uint24 length;
  HandshakeMessage message;
} Handshake;

// メッセージの内容は状態に依存する
// (ハンドシェイク中のある時点で送受信可能なメッセージが送信される
```

## 参照
- プロフェッショナルSSL/TLS
