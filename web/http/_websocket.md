# WebSocket
- 参照: [WebSockets](https://developer.mozilla.org/ja/docs/Glossary/WebSockets)
- 参照: よくわかるHTTP/2の教科書P128-130

## 概要
- サーバー-クライアント間のコネクションを維持し、永続的なTCP接続を行う通信規格
  - リアルタイムでの双方向通信を可能にする

## 詳細
- WebSocketの通信はクライアントから開始され、
  その後はクライアント・サーバーどちらからでもデータを送信できる
- クライアントサイドで実行されるJavaScriptとサーバーサイドのアプリケーションサーバーが
  WebSocketプロトコルを用いて双方向通信を行う
  - チャット・ゲームなど

## WebSocketの通信の確立
- (1)クライアントからWebSocketの通信要求を送信
  - HTTPヘッダにてWebSocketへのアップグレードを指定
```
upgrade: websocket
connection: upgrade
sec-websocket-version: クライアントのWebSocketのバージョン
sec-websocket-key: 通信確立時、実際にクライアントが要求したものと確認できるようにする値
sec-websocket-extensions: WebSocketで拡張機能を有効にするために使用する
```
- (2)サーバーがWebSocketに対応している場合、クライアントからの要求を受諾
  - HTTPヘッダにてWebSocketへのアップグレードを受諾
```
ステータスコード: 101
connection: upgrade
upgrade: websocket
sec-websocket-accept: リクエストヘッダのsec-websocket-keyから導出される値
```
- (3)クライアントが`sec-websocket-accept`の値を検証
- (4)最初にクライアントが送信したリクエストのTCPコネクションを切断せず双方向通信を開始
