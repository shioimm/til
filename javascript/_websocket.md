# WebSocket
- サーバー-クライアント間で一対一のコネクションを維持し、永続的なTCP接続を行うプロトコル及びJavaScript API↲
- JavaScript(クライアント側)とアプリケーションサーバー(サーバー側)が
  WebSocketプロトコルを用いて通信を行うことによって実現している

### 特徴
- リアルタイムでの双方向通信
- ステートフルな通信(サーバーはメモリ上あるいはKVSにデータを格納する)
- オーバーヘッドが小さい(2~14バイト)
- フレーム単位で送受信を行う
- 通信先の相手が決まっているため、送信先の情報は持たない
- テキストデータ(DOMStringオブジェクト)・バイナリデータ(Blobオブジェクト)を送受信する
- `ws://` / `wss://`で始まるURLを使用する
  - `ws`スキーム - 暗号化されていない通信に使用するカスタムURLスキーム
  - `wss`スキーム - 暗号化された通信(TCP + TLS)に使用するカスタムURLスキーム

## WebSocketプロトコルを構成する要素
- 接続パラメータをネゴシエートする開始ハンドシェイク
- テキストデータとバイナリデータのメッセージベース配信を小さなオーバーヘッドで行う
  バイナリメッセージフレーム化の仕組み

#### バイナリフレーミングレイヤー
- 送信元はアプリケーションメッセージを一つ以上のフレームに分割し、送信する
- 送信先はメッセージを再構成し、メッセージ全体を受信後、送信元へ終了メッセージを送信する
  - フレーム - コミュニケーションの最小単位・可変長のフレームヘッダとペイロードを含む
  - メッセージ - 論理的なアプリケーションメッセージを構成するフレームのシーケンス
- サイズの大きいメッセージは他のメッセージのフレーム送信をブロックする(インターリーブの仕組みがない)

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

## WebSocket API
```js
// 接続を作成
const socket = new WebSocket('ws://localhost:8080')

// 接続オープン時のイベントを登録
socket.addEventListener('open', function (event) {
  socket.send('Hello')
})

// メッセージの受信待機
socket.addEventListener('message', function (event) {
  // メッセージ受信時の処理
})
```

## サブプロトコルネゴシエーション
- メッセージに関する追加のメタ情報を送受信する際、
  クライアントとサーバー両方が解釈可能なサブプロトコルを利用する
- サブプロトコルをどのように扱うかクライアント・サーバー間であらかじめネゴシエーションが必要

```js
const socket = new WebSocket('ws://localhost:8080', ['protocol1', protocol2])

// ネゴシエーションに成功するとonopenコールバックが実行される
ws.onopen = function() {
  // サーバーによって選択されたプロトコルを確認
  if (ws.protocol == protocol1) {
    // ...
  }
}
```

## 参照
- [WebSockets](https://developer.mozilla.org/ja/docs/Glossary/WebSockets)
- [WebSocket API](https://developer.mozilla.org/ja/docs/Web/API/WebSocket)
- よくわかるHTTP/2の教科書P128-130
- Real World HTTP 第2版
- ハイパフォーマンスブラウザネットワーキング
