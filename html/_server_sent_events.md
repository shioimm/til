# Server-Sent Events
## TL:DR
- サーバーから任意のタイミングでクライアントにイベントを通知できる機能
  - HTTP/1.1のチャンク形式による通信機能を基にしている
- CometのロングポーリングとChunkedレスポンスを組み合わせ、
  一度のリクエストに対してサーバーから複数のイベント送信を行う
  - HTTP上にイベントストリ0むと呼ばれる別のテキストプロトコルを載せている
  - MIMEタイプはtext/event-stream
- JSからはEventSourceクラスを使ってServer-Sent Eventsにアクセスする

## イベントストリームのタグ

| 種類   | 説明                         |
| id     | イベントの識別子             |
| events | イベント名                   |
| data   | イベントともに送られるデータ |
| retry  | 再接続の待ち時間             |

## 参照
- [Server-sent events](https://developer.mozilla.org/ja/docs/Web/API/Server-sent_events)
- Real World HTTP 第2版
