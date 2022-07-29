# XMLHttpRequest
- JavaScriptでHTTP通信を実行するための機能
- curlコマンドと同等の操作を行うことができる
- 画面全体をクリアせずにWebページを読み込んだり更新するAjaxアーキテクチャの基幹技術として使用される

## ブラウザによるHTTPリクエストとの違い
- 送受信時にHTMLの画面がフラッシュされない
- GET / POST以外のメソッドを使用して送信できる
- プレーンテキスト、JSON、バイナリデータなど様々なフォーマットで送受信できる
  - フォームの場合キーと値が一対一になっている形式のデータ以外は送信できず、
    レスポンスはブラウザで表示される
- セキュリティのための制約を持つ

## XMLHttpRequestオブジェクト

```js
var xhr = new XMLHttpRequest()

xhr.open("GET", "/path", true) // 処理を設定・第三引数をtrueにすると非同期実行
xhr.responseType = "json" // レスポンスの型を指定
xhr.onload = fuction() {
  if (xhr.status == 200) {
    // レスポンス200時に呼ばれる処理
  }
}
xhr.setRequestHeader("Content-Type", "application/json")
zhr.send() // 処理を実行
```

## XMLHttpRequestがサポートするデータ型
- ArrayBuffer - 固定長のバイナリデータ
- Blob - 巨大なバイナリの不変データオブジェクト
- Document - パースされたHTML / XMLドキュメント
- JSON - JavaScriptオブジェクトと類似するデータ構造
- Text - シンプルな文字列

## XMLHttpRequest進行状況イベント

| イベントタイプ | 説明         | 発行される回数 |
| -              | -            | -              |
| loadstart      | 転送開始     | 1回            |
| progress       | 転送中       | 0回以上        |
| error          | 転送失敗     | 0回 or 1回     |
| abort          | 転送強制中断 | 0回 or 1回     |
| load           | 転送成功     | 0回 or 1回     |
| loadend        | 転送終了     | 1回            |

## Comet
- XMLHttpRequestによる単方向通信同士の組み合わせを駆使した古典的なリアルタイム双方向通信技術
- ロングポーリングによって実装される
- 現在はCometに替わり、チャンク形式を利用したより応答性の高いServer-Sent Eventsが使用される

### ポーリング
- 通知を受ける側が定期的に通知の有無を問い合わせる
- 何度もリクエストが発生するため送受信ともに帯域・CPUを消費する

### ロングポーリング(リバースAjax)
- クライアントからサーバーにリクエストが送られた後、その場でレスポンスを返さず保留したままにする
- サーバーからは自由なタイミングでレスポンスを返す
- 一メッセージあたりのオーバーヘッドが大きい
- サーバーからメッセージを返した後、通信を行うために再びクライアント側からセッションを張り直す必要がある

## XMLHttpRequest利用時のセキュリティ上の制約
### アクセスできる情報の制限
- Cookieの制限
  - CookieにhttpOnly属性を付与し、スクリプトからアクセスできないようにする

### 送信制限
- リクエストを送信する先のドメインの制限(CORS)
- リクエストを送信するために利用できるHTTPメソッドの制限
  - CONNECT、TRACE、TRACK以外
- リクエストを送信する際のヘッダの制限
  - プロトコルのルールや環境に影響を与えるヘッダの送信禁止
  - セキュリティに影響を与えるヘッダの送信禁止
  - ブラウザの能力を超えられないヘッダの送信禁止

## 参照
- [XMLHttpRequest](https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest)
- Real World HTTP 第2版
- ハイパフォーマンスブラウザネットワーキング
