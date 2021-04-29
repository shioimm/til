# Server-Sent Events
## TL:DR
- サーバーから任意のタイミングでクライアントにイベントを通知するためのプロトコル及びJavaScript API
  - HTTP/1.1のチャンク形式による通信機能を基にしている
- CometのロングポーリングとChunkedレスポンスを組み合わせ、
  一度のリクエストに対してサーバーから複数のイベント送信を行う
  - HTTP上にイベントストリームと呼ばれる別のテキストプロトコルを載せている
  - MIMEタイプはtext/event-stream
- JavaScriptからはEventSourceクラスを使ってServer-Sent Eventsにアクセスする

## イベントストリームのタグ

| 種類   | 説明                         |
| id     | イベントの識別子             |
| events | イベント名                   |
| data   | イベントともに送られるデータ |
| retry  | 再接続の待ち時間             |

## EventSource

```js
const evtSource = new EventSource(イベントを生成するスクリプト);

evtSource.onmessage = e => {
  // サーバからのメッセージ受信時の処理
  // メッセージにはe.dataでアクセス可能
};
```

## 参照
- [Server-sent events](https://developer.mozilla.org/ja/docs/Web/API/Server-sent_events)
- Real World HTTP 第2版
