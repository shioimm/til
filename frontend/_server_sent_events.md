# Server-Sent Events
- サーバーから任意のタイミングでクライアントにイベントを通知するためのプロトコル及びJavaScript API
  - HTTP/1.1のチャンク形式による通信機能を基にしている
- CometのロングポーリングとChunkedレスポンスを組み合わせ、
  一度のリクエストに対してサーバーから複数のイベント送信を行う
  - HTTP上にイベントストリームと呼ばれる別のテキストプロトコルを載せている
  - MIMEタイプはtext/event-stream
- JavaScriptからはEventSource APIを使ってServer-Sent Eventsにアクセスする

### 構成要素
- EventResource API - サーバーからのプッシュ通知をクライアントがDOMイベントとして取得するAPI
- event stream データフォーマット - アップデートを配信する際に利用するデータフォーマット

## EventSource API
- 接続確立やメッセージ解析などの低レベル作業を抽象化したブラウザAPI

```js
const evtSource = new EventSource(ストリームエンドポイント);

evtSource.onmessage = e => {
  // サーバからのメッセージ受信時のコールバック処理を記述
  // メッセージにはe.dataでアクセス可能
};
```

## event stream データフォーマット
- ストリーム内のメッセージのIDやタイプ、境界を定義するフォーマット
  - ストリームはHTTPレスポンスのストリームとして`text/event-stream` Content-Typeで配信される
  - ストリームはUTF-8文字列のイベントデータ(バイナリデータを扱いたい場合はWebSocketを利用する)
  - メッセージは2つの改行文字で区切られる

### メッセージフィールド

| フィールド名   | 説明                         |
| id             | イベントの識別子             |
| events         | イベント名                   |
| data           | イベントともに送られるデータ |
| retry          | 再接続の待ち時間             |

## 参照
- [Server-sent events](https://developer.mozilla.org/ja/docs/Web/API/Server-sent_events)
- Real World HTTP 第2版
- ハイパフォーマンスブラウザネットワーキング
