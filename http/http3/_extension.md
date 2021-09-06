# 拡張
## WebTransport
- WebSocketのようなクライアントとサーバー間の双方向通信においてQUICやHTTP/3を利用するための技術
- QUICの`DATAGRAM`フレーム拡張を利用する

## MASQUE
- HTTP/3上で動作し、通信のトンネリングに利用できる技術
- HTTP/3通信を確立した後、当該QUICコネクション上で別の通信をトンネリングさせることにより
  安全な通信路であるVPNを確立する
- MASQUEクライアントはMASQUEプロキシ(中継者)にHTTP/3で接続し、
  本来の通信先を転送先として指定して通信を行う

## 参照
- WEB+DB PRESS Vol.123 HTTP/3入門
