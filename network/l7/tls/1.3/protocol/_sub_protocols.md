# サブプロトコル群
- 各プロトコルによるメッセージはRecordプロトコルによってラップされ転送される

#### Alertプロトコル
- シグナリングおよび例外的な状況で使われるサブプロトコル
  - ハンドシェイクを完遂できない場合に接続が切れることを相手に通知する場合など

#### Application Data プロトコル
- アプリケーションデータの転送に使われるサブプロトコル
- 書式を問わないバイト列として通信の一方から他方へとデータを送るためのメッセージのみを持つ

#### Change Cipher Specプロトコル
- TLS1.3では非推奨
- クライアント、サーバー共にChange Cipher Specプロトコルの各メッセージを送信しても受信側で無視される

#### Handshakeプロトコル
- 接続で利用するセキュリティパラメータをネゴシエーションする際に使われるサブプロトコル

# 参照
- プロフェッショナルSSL/TLS
