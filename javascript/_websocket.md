# WebSocket
## TL;DR
- サーバー-クライアント間で一対一のコネクションを維持し、
  永続的なTCP接続を行う通信の仕組み
- JavaScript(クライアント側)とアプリケーションサーバー(サーバー側)が
  WebSocketプロトコルを用いて通信を行うことによって実現している

### 特徴
- リアルタイムでの双方向通信
- ステートフルな通信(サーバーはメモリ上あるいはKVSにデータを格納する)
- オーバーヘッドが小さい(2~14バイト)
- フレーム単位で送受信を行う
- 通信先の相手が決まっているため、送信先の情報は持たない
- `ws://` / `wss://`で始まるURLを使用する

## 通信の確立
1. サーバーが特定のIPアドレス、ポート番号でサーバーを起動
2. クライアントがサーバーへ通信開始を宣言
3. サーバーがクライアントからの接続要求を受け入れる
4. サーバーにソケットクラスのインスタンスが渡される
5. サーバーが受理するとクライアントのソケットの送受信機能が有効になる

### HTTP/2
```
1. 通常のHTTPとして通信を開始する
2. クライアントからサーバーへWebSocketの通信要求を送信
   リクエスト疑似ヘッダにてWebSocketへのアップグレードを指定する

     :method   = CONNECT
     :protocol = websocket
     :sec-websocket-protocol = サブプロトコル

3. サーバーがWebSocketに対応している場合、クライアントからの要求を受諾
   レスポンス疑似ヘッダにてWebSocketへのアップグレードを受諾

     :status = 200
     :sec-websocket-protocol = クライアントから送信されたサブプロトコルのうち一つ

4. 以降はDATAフレームを使用して双方向通信を行う
```

### HTTP/1.1
```
1. 通常のHTTPとして通信を開始する
2. クライアントからWebSocketの通信要求を送信
   リクエストヘッダにてWebSocketへのアップグレードを指定する

     Upgrade: websocket
     Connection: Upgrade
     Sec-Websocket-Key: ランダムな16バイトの値をbase64エンコードした文字列

3. サーバーがWebSocketに対応している場合、クライアントからの要求を受諾
  レスポンスヘッダにてWebSocketへのアップグレードを受諾

     HTTP/1.1 101 Switcing Protocols
     upgrade: websocket
     connection: Upgrade
     Sec-Websocket-Accept: リクエストヘッダのSec-Websocket-Keyから導出される値
     Sec-Websocket-Protocol: サブプロトコル

3. クライアントがSec-Websocket-Acceptの値を検証
4. 最初にクライアントが送信したリクエストのTCPコネクションを使って双方向通信を開始
```

## 参照
- [WebSockets](https://developer.mozilla.org/ja/docs/Glossary/WebSockets)
- よくわかるHTTP/2の教科書P128-130
- Real World HTTP 第2版
