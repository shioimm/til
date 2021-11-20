# HTTP/2で拡張できる機能
- フレームタイプ
- SETTINGSパラメータ
- エラーコード

### 拡張仕様の重複
- フレームタイプ番号(HTTP/2 Frame Type)、
  SETTINGSパラメータ番号(HTTP/2 Setting)、
  エラーコード(HTTP/2 Error Code)は
  既存の仕様・実装と重複している場合、正しく動作しない

## 拡張機能仕様の合意
- 既存の実装に影響を与えうる拡張機能の場合は、
  サーバー - クライアント共に対応していることを確認してから使用する
  - クライアント -> サーバーへ`SETTINGS_CAPABLE_EXTENSION_XXXX`パラメータを送信
  - クライアント <- サーバーへ`SETTINGS` Ackを送信

## フレームタイプ
#### `ALTSRV`フレーム
- クライアント <- サーバー: サービスの別の提供方法を通知する
  - オリジン(URLのスキーム、ドメイン名、ポート番号)
  - オリジンを提供できる代替エンドポイントおよび代替プロトコル

#### `ORIGIN`フレーム
- クライアント <- サーバー: サーバーが提供できるオリジンのリストを通知する

## WebSockets with HTTP/2
- TCPコネクション上に張られるストリームのうち、一つをWebSocket用通信に切り替える拡張
- クライアントとサーバーが双方に`SETTINGS_ENABLE_CONNECT_PROTOCOL`パラメータを送信し合うことにより
  拡張に対応していることを確認し合い、WebSocketの利用に合意する
- 合意後、クライアントからHTTPの`CONNECT`メソッドのリクエストで`:protocol = websocket`を送信し、
  WebSocket 通信を開始する

### 参照
- よくわかるHTTP/2の教科書P126
- WEB+DB PRESS Vol.123 HTTP/3入門
